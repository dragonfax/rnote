
require 'nokogiri'
require 'yaml'

require 'evernote-thrift'

module Evernote::EDAM::Error

  # converting between text formats and enml
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
  
  class InvalidFormatError < Exception
  end
  
  class InvalidXmlError < InvalidFormatError
    
    attr_reader :xml
    
    def initialize(message, xml=nil)
      @xml = xml
      super(message)
    end
  end
  
  class InvalidMarkdownError < InvalidFormatError
    def initialize(message, markdown=nil)
      @markdown = markdown
      super(message)
    end
  end
  
end
  
class Evernote::EDAM::Type::Note
  
  def self.enml_to_markdown(enml)
    enml_to_txt(enml)
  end

  def self.markdown_to_enml(markdown)
    txt_to_enml(markdown)
  end
  
  def markdown_content=(markdown_content)
    self.content = self.class.markdown_to_enml(markdown_content)
  end
  
  def markdown_content
    self.class.enml_to_markdown(content)
  end
  
  def self.enml_to_txt(enml)
    document =  Nokogiri::XML::Document.parse(enml)
    raise Evernote::EDAM::Error::InvalidXmlError.new("invalid xml",enml) unless document.root
    pre_node = document.root.xpath('pre').first
    if pre_node
      pre_node.children.to_ary.select { |child| child.text? }.map { |child| child.to_s }.join('')
    else
      document.root.xpath("//text()").text
    end  
  end
  
  def self.txt_to_enml(txt)
    if txt.start_with? '<?xml'
      raise Evernote::EDAM::Error::InvalidMarkdownError.new('given xml instead of txt')
    end
    <<EOF
<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note>
<pre>#{txt}</pre>
</en-note>
EOF
  end
  
  def txt_content=(txt_content)
    self.content = self.class.txt_to_enml(txt_content)
  end
  
  def txt_content
    self.class.enml_to_txt(content)
  end
  
  # The yaml stream is what we give to the user to edit in their editor
  # 
  # Its just a string, but its composed of 2 parts. the note attributes and the note content.
  #
  # 1. a small yaml document with the note attributes as a hash.
  # 2. followed by the note content as markdown
  def yaml_stream=(yaml_stream)

    m = yaml_stream.match /^(---.+?---\n)(.*)$/m
    raise "failed to parse yaml stream\n#{yaml_stream}" unless m

    attributes_yaml = m[1]
    markdown = m[2]

    enml = self.class.txt_to_enml(markdown)
    attributes_hash = YAML.load(attributes_yaml)
    
    # process tag names
    # allow for comma separated tag list
    tag_names = attributes_hash['tagNames']
    tag_names = tag_names.split(/\s*,\s*/) if tag_names.instance_of?(String)

    self.title = attributes_hash['title']
    self.tagNames = attributes_hash['tagNames']
    self.content = enml
  end
  
  def yaml_stream
    YAML.dump({ 'title' => title, 'tagNames' => tagNames }) + "\n---\n" + self.class.enml_to_txt(content)
  end
  
  def summarize
    self.txt_content.strip.gsub(/\s+/,' ')[0..100]
  end

end
