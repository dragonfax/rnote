
require 'nokogiri'
require 'yaml'

module Rnote

  class Converter

    def enml_to_raw_markdown(enml)
      document =  Nokogiri::XML::Document.parse(enml)
      pre_node = document.root.xpath('pre').first
      if pre_node
        pre_node.children.to_ary.select { |child| child.text? }.map { |child| child.to_s }.join('')
      else
        document.root.xpath("//text()").text
      end
    end

    def raw_markdown_to_enml(markdown)
      <<-EOF
<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note>
<pre>#{markdown}</pre>
</en-note>
EOF
    end

    # The yaml stream is what we give to the user to edit in their editor
    #
    # Yaml stream is a yaml document with the note details as a hash.
    # followed by the note content as markdown
    def yaml_stream_to_attributes(yaml_stream)

      m = yaml_stream.match /^(---.+?---\n)(.*)$/m
      raise "failed to match input\n#{yaml_stream}" unless m

      attributes_doc = m[1] || raise
      markdown = m[2]

      attributes = YAML.load(attributes_doc)
      enml = raw_markdown_to_enml(markdown)

      attributes[:content] = enml

      attributes
    end

    def attributes_to_yaml_stream(attributes)

      enml = attributes[:content]
      attributes.delete(:content)

      YAML.dump(attributes) + "\n---\n" + enml_to_raw_markdown(enml)
    end

  end


end
