
require 'minitest/autorun'
require 'evernote'

module EvernoteCLI

  describe Converter do
    before do
      @converter = Converter.new
    end

    describe 'raw markdown' do

      it 'passes a simple text, with no markup, through unaltered' do
        assert_equal('simple text', @converter.enml_to_raw_markdown(@converter.raw_markdown_to_enml('simple text')))
      end

    end

    describe 'attributes markdown' do

      it 'passes simple text, with no markup, through unaltered' do
        yaml_stream = <<EOF
---
title: blah

---
simple text
EOF
        assert_equal(yaml_stream, @converter.attributes_to_yaml_stream(@converter.yaml_stream_to_attributes(yaml_stream)))
      end

    end

  end

end