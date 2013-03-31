

require 'minitest/autorun'
require 'rnote/converter'
require 'nokogiri'

module Rnote

  describe 'simple document conversions' do

    describe 'enml2md' do

      it 'converts a <pre> tag to md verbatim' do
        assert_equal "test1",Evernote::EDAM::Type::Note.enml_to_markdown(<<EOF)
<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note><pre>test1</pre></en-note>
EOF
       end

      it 'fails if receives invalid enml' do
        assert_raises(Evernote::EDAM::Error::InvalidXmlError) do
          Evernote::EDAM::Type::Note.enml_to_markdown('invalid enml')
        end
      end

      it 'strips the tags from enml' do
        assert_equal "test2",Evernote::EDAM::Type::Note.enml_to_markdown(<<EOF)
<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note><div><div>test2</div></div></en-note>
EOF
      end

      it 'failed with an empty document' do

        assert_raises(Evernote::EDAM::Error::InvalidXmlError) do
          Evernote::EDAM::Type::Note.enml_to_markdown('')
        end

      end

      it 'succeeds with an empty root' do
        assert_equal "",Evernote::EDAM::Type::Note.enml_to_markdown(<<EOF)
<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note></en-note>
EOF
      end

    end

    describe 'md2enml' do

      it 'fails if it receives xml instead of md' do
        assert_raises(Evernote::EDAM::Error::InvalidMarkdownError) do
          Evernote::EDAM::Type::Note.markdown_to_enml(<<EOF)
<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note></en-note>
EOF
        end
      end

      it 'succeeds with a simple document' do
        enml = Evernote::EDAM::Type::Note.markdown_to_enml('test4')
        assert enml.include?('test4')
        assert Nokogiri::XML::Document.parse(enml)
      end

      it 'succeeds with an empty document' do
        Evernote::EDAM::Type::Note.markdown_to_enml('')
      end


    end

    describe 'combined, encode + decode' do

      it 'passes through simple text (markdown), with no markup' do
        assert_equal('simple text', Evernote::EDAM::Type::Note.enml_to_markdown(Evernote::EDAM::Type::Note.markdown_to_enml('simple text')))
      end

      it 'passes through simple enml, with no content markup' do
        enml = Evernote::EDAM::Type::Note.markdown_to_enml(Evernote::EDAM::Type::Note.enml_to_markdown(<<EOF))
<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note><pre>simple text</pre></en-note>
EOF
        assert Nokogiri::XML::Document.parse(enml)
        assert enml.include?('simple text')
      end

    end

  end

  describe Evernote::EDAM::Type::Note do

    it 'passes through simple yaml_stream, with no markup' do
      yaml_stream = <<EOF
---
title: blah

---
simple text
EOF
      note = Evernote::EDAM::Type::Note.new
      note.yaml_stream = yaml_stream
      assert_equal yaml_stream, note.yaml_stream
    end

    it 'passes through simple Note, with no markup' do

      enml = <<EOF
<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note><pre>simple text</pre></en-note>
EOF

      note = Evernote::EDAM::Type::Note.new
      note.content = enml
      
      note2 = Evernote::EDAM::Type::Note.new
      note2.markdown_content = note.markdown_content
      
      refute_nil note2.content
      assert note2.content.include?('simple text')
    end

  end

end