
require 'nokogiri'
require 'yaml'

require 'evernote-thrift'


# converting between text formats and enml
#
# we have two types of conversion
#
# simple,
# single document conversion.
# which is enml <=> txt
#
# then our own additional wrappers we put on top of those 2 document types
# adding metadata to them.
# yaml_stream <=> notes attributes
# content is just considered an 'attribute' in the latter
#
# the yaml_stream is just a string
# the note attributes get its own class and thats where we stick the conversion routines.

class Evernote::EDAM::Type::Note

  # Nokogiri SAX parser
  class EnmlDocument < Nokogiri::XML::SAX::Document
    
    attr_accessor :txt

    def initialize
      @txt = ''
      super
    end
    
    def characters string
      # Evernote seems to consider whitespace inside a div significant.
      # but puts a newline after each div as well.
      # I'm not sure what their intention is. But rather than include all these extra newlines (on top of the <br/>s)
      # I cheap out and just remove any newlines I see in the content.
      # unless its in a pre tag
      @txt << string
    end
    
    def start_element name, attrs = []
      if name == 'en-todo'
        if Hash[attrs]['checked'] == 'true'
          @txt << '[X]'
        else
          @txt << '[ ]'
        end
      end
    end
    
  end


  def self.enml_to_txt(enml)
    raise 'not given xml' if ! enml.start_with? '<?xml'

    sax_document = EnmlDocument.new
    parser = Nokogiri::XML::SAX::Parser.new(sax_document)
    parser.parse(enml)
    
    enml = sax_document.txt

    enml
  end
  
  def self.txt_to_enml(txt)
    raise 'given xml instead of txt' if txt.start_with? '<?xml'
    
    # escape any angle brackets
    txt.gsub!('<','&lt;')
    txt.gsub!('>','&gt;')
    
    # replace todo items 
    txt.gsub!('[ ]','<en-todo checked="false"/>')
    txt.gsub!('[X]','<en-todo checked="true"/>')
    
    # split by newlines, do the swap to div/br
    # an empty string at the end of the split means there was a newline on the last real line.
    lines = txt.split("\n",-1)
    if txt == ""
      # special case
      lines = ['']
    else
      if lines.length == 0
        raise
      end
    end
    last_line = lines.pop
    xhtml = lines.map { |string|
      "<div>#{string}<br/></div>\n"
    }.join('')
    if last_line == ""
      # last real line in txt had a newline
      # this was perofrmed by the map above
      # our deed is done
    else
      # this is the last real line of txt
      # and it has no newline
      # so we must convert it specially
      xhtml << "<div>#{last_line}</div>\n"
    end
      
    <<EOF
<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note>
#{xhtml}</en-note>
EOF
  end
  
  def self.enml_to_format(format,enml)
    case format
      when 'enml'
        enml
      when 'txt'
        enml_to_txt(enml)
      else 
        raise
    end
  end
  
  def self.format_to_enml(format,formatted_content)
    case format
      when 'enml'
        formatted_content
      when 'txt'
        txt_to_enml(formatted_content)
      else
        raise
    end
  end
  
  def txt_content
    self.class.enml_to_format('txt',self.content)
  end
  
  # The yaml stream is what we give to the user to edit in their editor
  # 
  # Its just a string, but its composed of 2 parts. the note attributes and the note content.
  #
  # 1. a small yaml document with the note attributes as a hash.
  # 2. followed by the note content as txt
  def set_yaml_stream(format,yaml_stream)

    m = yaml_stream.match /^(---.+?---\n)(.*)$/m
    raise "failed to parse yaml stream\n#{yaml_stream}" unless m

    attributes_yaml = m[1]
    txt = m[2]

    enml = self.class.format_to_enml(format,txt)
    attributes_hash = YAML.load(attributes_yaml)
    
    # process tag names
    # allow for comma separated tag list
    tag_names = attributes_hash['tagNames']
    tag_names = tag_names.split(/\s*,\s*/) if tag_names.instance_of?(String)

    self.title = attributes_hash['title']
    self.tagNames = attributes_hash['tagNames']
    self.content = enml
  end
  
  def yaml_stream(format)
    YAML.dump({ 'title' => title, 'tagNames' => tagNames }) + "\n---\n" + self.class.enml_to_format(format,content)
  end
  
  def summarize
    self.txt_content.strip.gsub(/\s+/,' ')[0..100]
  end

end
