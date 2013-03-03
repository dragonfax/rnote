
require 'nokogiri'
require 'yaml'

module Rnote

  # converting between markdown and enml
  #
  # we have two types of conversion
  #
  # simple,
  # single document conversion.
  # which is enml <=> markdown
  #
  # then our own additional wrappers we put on top of those 2 document types
  # adding metadata to them.
  # yaml_stream <=> notes attributes
  # content is just considered an 'attribute' in the latter
  #
  # the yaml_stream is just a string
  # the note attributes get its own class and thats where we stick the conversion routines.
  
  class InvalidXmlError < Exception 
  end
  
  class InvalidMarkdownError < Exception
  end
  
  def Rnote.enml_to_markdown(enml)
    document =  Nokogiri::XML::Document.parse(enml)
    raise InvalidXmlError.new("invalid xml") unless document.root
    pre_node = document.root.xpath('pre').first
    if pre_node
      pre_node.children.to_ary.select { |child| child.text? }.map { |child| child.to_s }.join('')
    else
      document.root.xpath("//text()").text
    end
  end

  def Rnote.markdown_to_enml(markdown)
    if markdown.start_with? '<?xml'
      raise InvalidMarkdownError.new('given xml instead of markdown')
    end
    <<-EOF
<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note>
<pre>#{markdown}</pre>
</en-note>
EOF
  end

  class NoteAttributes < Struct.new(:title, :guid, :enml)
    # the form of a note that this library passes around internally.

    # TODO just add these methods to evernotes own note type. and get rid of this class

    def NoteAttributes.from_note(note)
      NoteAttributes.new(note.title,note.guid,note.content)
    end

    def to_note
      note = Evernote::EDAM::Type::Note.new
      note.title = title
      note.guid = guid
      note.content = enml
    end

    def _to_yaml_attributes
      # when we convert to yaml, for the document header, we don't include the enml
      # that gets appended to the end of the document seperately
      {
          'title' => title,
          'guid' => guid
      }
    end

    def NoteAttributes._from_yaml_attributes(yaml_attributes,enml)
      # after loading the attributes from the yaml stream, we have to recreate this structure
      NoteAttributes.new(yaml_attributes['title'],yaml_attributes['guid'],enml)
    end

    # The yaml stream is what we give to the user to edit in their editor
    #
    # Yaml stream is just a string.
    # a yaml document with the note attributes as a hash.
    # followed by the note content as markdown
    def NoteAttributes.from_yaml_stream(yaml_stream)

      m = yaml_stream.match /^(---.+?---\n)(.*)$/m
      raise "failed to parse yaml stream\n#{yaml_stream}" unless m

      attributes_yaml = m[1]
      markdown = m[2]

      enml = Rnote.markdown_to_enml(markdown)
      attributes_hash = YAML.load(attributes_yaml)

      NoteAttributes._from_yaml_attributes(attributes_hash,enml)
    end

    def to_yaml_stream()
      YAML.dump(_to_yaml_attributes) + "\n---\n" + Rnote.enml_to_markdown(enml)
    end

  end


end
