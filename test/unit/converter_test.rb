
require 'minitest/autorun'
require 'rnote/converter'
require 'nokogiri'

module Rnote

  describe 'simple document conversions' do

    # first test specific directions
    # if we have conversion issues, I'll add tests here to nail down whats going wrong.

    describe 'enml2txt' do

      it 'converts a <pre> tag to txt verbatim' do
        enml = <<EOF
<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note><div>test1<br/></div></en-note>
EOF
        assert_equal "test1\n",Evernote::EDAM::Type::Note.enml_to_txt(enml)
      end

      it 'fails if receives invalid enml' do
        assert_raises(RuntimeError) do
          Evernote::EDAM::Type::Note.enml_to_txt('invalid enml')
        end
      end

      it 'strips the tags from enml' do
        assert_equal "test2",Evernote::EDAM::Type::Note.enml_to_txt(<<EOF)
<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note><div><div>test2</div></div></en-note>
EOF
      end

      it 'failed with an empty document' do

        assert_raises(RuntimeError) do
          Evernote::EDAM::Type::Note.enml_to_txt('')
        end

      end

      it 'succeeds with an empty root' do
        assert_equal "",Evernote::EDAM::Type::Note.enml_to_txt(<<EOF)
<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note></en-note>
EOF
      end

    end

    describe 'txt2enml' do

      it 'fails if it receives xml instead of txt' do
        assert_raises(RuntimeError) do
          Evernote::EDAM::Type::Note.txt_to_enml(<<EOF)
<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note></en-note>
EOF
        end
      end

      it 'succeeds with a simple document' do
        enml = Evernote::EDAM::Type::Note.txt_to_enml('test4')
        assert enml.include?('test4')
        assert Nokogiri::XML::Document.parse(enml)
      end

      it 'succeeds with an empty document' do
        Evernote::EDAM::Type::Note.txt_to_enml('')
      end


    end

    describe 'combined, encode + decode' do

      # this is how I really like to test the formatting conversion.
      # it tests both directions in one go.
      # and verifies we reverse the conversion exactly.

      it 'passes through simple text (txt), with no markup' do
        assert_equal('simple text', Evernote::EDAM::Type::Note.enml_to_txt(Evernote::EDAM::Type::Note.txt_to_enml('simple text')))
      end

      it 'passes through simple enml, with no content markup' do
        enml = Evernote::EDAM::Type::Note.txt_to_enml(Evernote::EDAM::Type::Note.enml_to_txt(<<EOF))
<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note><div>simple text<br/></div></en-note>
EOF
        assert Nokogiri::XML::Document.parse(enml)
        assert enml.include?('simple text')
      end

      it 'multiple lines, ends with a newline' do
        txt = <<EOF
line 1
a second line
even a third
EOF
        assert txt.end_with? "\n"
        assert_equal(txt, Evernote::EDAM::Type::Note.enml_to_txt(Evernote::EDAM::Type::Note.txt_to_enml(txt)))
      end

      it "multiple lines, doesn't end with a newline" do
        txt = <<EOF
line 1
a second line
even a third
EOF
        txt << 'and a final line with no newline'
        refute txt.end_with? "\n"
        assert_equal(txt, Evernote::EDAM::Type::Note.enml_to_txt(Evernote::EDAM::Type::Note.txt_to_enml(txt)))
      end

      it 'whitespace in txt is preserved' do
        assert_equal('  simple text', Evernote::EDAM::Type::Note.enml_to_txt(Evernote::EDAM::Type::Note.txt_to_enml('  simple text')))
      end

      it 'todo item (checked) is preserved' do
        assert_equal('[X] simple text', Evernote::EDAM::Type::Note.enml_to_txt(Evernote::EDAM::Type::Note.txt_to_enml('[X] simple text')))
      end

      it 'todo item (unchecked) is preserved' do
        assert_equal('[ ] simple text', Evernote::EDAM::Type::Note.enml_to_txt(Evernote::EDAM::Type::Note.txt_to_enml('[ ] simple text')))
      end

      it 'pre tag is converted properly, but not preserved' do
        enml_with_pre = <<EOF
<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note>
<pre>Here is some pre text
  with some whitespace
and some new lines
</pre></en-note>
EOF
        enml_without_pre = <<EOF
<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note>
<div>Here is some pre text<br/></div>
<div>  with some whitespace<br/></div>
<div>and some new lines<br/></div>
</en-note>
EOF
        assert_equal(enml_without_pre, Evernote::EDAM::Type::Note.txt_to_enml(Evernote::EDAM::Type::Note.enml_to_txt(enml_with_pre)))
      end

    end

  end

  describe Evernote::EDAM::Type::Note do

    # test that we've instrumented the Note type properly.

    it 'passes through simple yaml_stream, with no markup' do
      yaml_stream = <<EOF
---
title: blah
tagNames: 

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
<en-note><div>simple text<br/></div></en-note>
EOF

      note = Evernote::EDAM::Type::Note.new
      note.content = enml
      
      note2 = Evernote::EDAM::Type::Note.new
      note2.txt_content = note.txt_content
      
      refute_nil note2.content
      assert note2.content.include?('simple text')
    end

  end

end