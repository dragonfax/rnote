
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
    
    attr_reader :xml
    
    def initialize(message, xml=nil)
      @xml = xml
      super(message)
    end
  end
  
  class InvalidMarkdownError < Exception
    def initialize(message, markdown=nil)
      @markdown = markdown
      super(message)
    end
  end
  
  def Rnote.enml_to_markdown(enml)
    document =  Nokogiri::XML::Document.parse(enml)
    raise InvalidXmlError.new("invalid xml",enml) unless document.root
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



end
