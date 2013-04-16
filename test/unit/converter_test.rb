
require 'minitest/autorun'
require 'rnote/noun/note/converter'
require 'nokogiri'
require_relative '../test_helper'

# please see docs on formats and format conversion.

module Rnote

  describe 'format conversions' do

    describe 'Note.enml_to_txt' do
      
      # tests for the interface, but not the actual conversion

      it 'fails if receives invalid enml' do
        assert_raises(RuntimeError) do
          Evernote::EDAM::Type::Note.enml_to_txt('invalid enml')
        end
      end
      
      it 'failed with an empty document' do

        assert_raises(RuntimeError) do
          Evernote::EDAM::Type::Note.enml_to_txt('')
        end

      end
      
      it 'succeeds with an empty root' do
        assert_equal "",Evernote::EDAM::Type::Note.enml_to_txt(<<-EOF.unindent)
          <?xml version='1.0' encoding='utf-8'?>
          <!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
          <en-note></en-note>
        EOF
      end
      
    end
    

    describe 'Note.txt_to_enml' do
      
      # just some verification of the error handling.

      it 'fails if it receives xml instead of txt' do
        assert_raises(RuntimeError) do
          Evernote::EDAM::Type::Note.txt_to_enml(<<-EOF.unindent)
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
    
    describe 'enml -> txt -> enml' do
      
      # I'm not sure of the need for verifying this.
      # but more consistency is always good.
    
      it 'passes through simple enml, with no content markup' do
        enml = Evernote::EDAM::Type::Note.txt_to_enml(Evernote::EDAM::Type::Note.enml_to_txt(<<-EOF.unindent))
          <?xml version='1.0' encoding='utf-8'?>
          <!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
          <en-note><div>simple text<br/></div></en-note>
        EOF
        assert Nokogiri::XML::Document.parse(enml)
        assert enml.include?('simple text')
      end
      
    end

    describe 'txt -> enml -> txt' do

      # this is how I really like to test the formatting conversion.
      # it tests both directions in one go.
      # and verifies we reverse the conversion exactly.
      # this is the conversion which has to be perfect. nothing lost or gained.
      
      def assert_txt_converted(txt)
        assert_equal(txt, Evernote::EDAM::Type::Note.enml_to_txt(Evernote::EDAM::Type::Note.txt_to_enml(txt)).replace_nbsp)
      end

      it 'passes through simple text (txt), with no markup' do
        assert_txt_converted('simple text')
      end


      it 'multiple lines, ends with a newline' do
        txt = <<-EOF.unindent
          line 1
          a second line
          even a third
        EOF
        assert txt.end_with? "\n" # sanity check. as this is vital to the test
        
        assert_txt_converted(txt)
      end

      it "multiple lines, doesn't end with a newline" do
        txt = <<-EOF.unindent.chomp
          line 1
          a second line
          even a third
        EOF
        refute txt.end_with? "\n" # sanity check, as this is vital to the test
        
        assert_txt_converted(txt)
      end

      it 'whitespace in txt is preserved' do
        assert_txt_converted('  simple text')
      end

      it 'todo item (checked) is preserved' do
        assert_txt_converted('[X] simple text')
      end

      it 'todo item (unchecked) is preserved' do
        assert_txt_converted('[ ] simple text')
      end
      
      
      
      it 'note with multiple lines, newline at the end, newline preserved' do
        txt = "line 1\nline 2\nline 3\n"
        assert_txt_converted(txt)
      end
      
      it 'note with multiple lines, no newline at the end, preserved' do
        txt = "line 1\nline 2\nline 3"
        assert_txt_converted(txt)
      end
      
      it 'note with multiple lines, blank line at the end (2 newlines), preserved' do
        txt = "line 1\nline 2\nline 3\n\n"
        assert_txt_converted(txt)
      end
      
      it 'multiple lines with varying indent' do
        txt = <<-EOF.unindent
        
          first line, will seem unindented

            second line, is indented one tab

              third line, is indented two tabs

          fourth line, is not indented at all.

        EOF
        assert_txt_converted(txt)
      end


    end
    
    describe 'converting other formats' do
    
      # this pre tag is how we used to do formating.
      # may crop up againt, too
      it 'pre tag, converted but not preserved' do
        enml_with_pre = Evernote::EDAM::Type::Note::ENML_PREAMBLE + <<-EOF.unindent
          <pre>Here is some pre text
            with some whitespace
          and some new lines
          </pre></en-note>
        EOF
        enml_without_pre = Evernote::EDAM::Type::Note::ENML_PREAMBLE + <<-EOF.unindent
          <div>Here is some pre text</div>
          <div>  with some whitespace</div>
          <div>and some new lines</div>
          </en-note>
        EOF
        assert_equal(enml_without_pre, Evernote::EDAM::Type::Note.txt_to_enml(Evernote::EDAM::Type::Note.enml_to_txt(enml_with_pre)).replace_nbsp)
      end
      
      it 'extracts text from a <pre> tag' do
        enml = <<-EOF.unindent
          <?xml version='1.0' encoding='utf-8'?>
          <!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
          <en-note><div>test1<br/></div></en-note>
        EOF
        # TODO the <br> is really ignored? strange
        assert_equal "test1",Evernote::EDAM::Type::Note.enml_to_txt(enml)
      end
      
      it 'strips the tags from enml' do
        assert_equal "test2",Evernote::EDAM::Type::Note.enml_to_format('txt',<<-EOF.unindent)
          <?xml version='1.0' encoding='utf-8'?>
          <!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
          <en-note><div>test2</div></en-note>
        EOF
      end

      it 'nested divs with list items' do
        
        enml = <<-EOF.unindent
          <?xml version='1.0' encoding='utf-8'?>
          <!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
          <en-note>
          <div>
          <ol>
          <li>ol item 1<br/></li>
          <li>ol item 2</li>
          </ol>
          <div><b>also</b></div>
          <ol>
          <li>ol item 1<br/>
          * ul item 1
          * ul item 2
          <li>ol item 1</li>
          </ol>
          </div>
          </en-note>
        EOF
        
        txt = <<-EOF.unindent
          1. ol item 1
          2. ol item 2
          
          also
          
          1. ol item 1
          * ul item 1
          * ul item 2
          2. ol item 1
          
        EOF

        assert_equal txt,Evernote::EDAM::Type::Note.enml_to_txt(enml)
      end
 
    end

  end

  describe Evernote::EDAM::Type::Note do

    # test that we've instrumented the Note type properly.

    it 'set_yaml_stream' do
      yaml_stream = <<-EOF.unindent
        ---
        title: blah
        tagNames: 
        
        ---
        simple text
      EOF
      note = Evernote::EDAM::Type::Note.new
      note.set_yaml_stream('txt',yaml_stream)
      assert_equal yaml_stream, note.yaml_stream('txt')
    end

    it 'txt_content' do

      enml = <<-EOF.unindent
        <?xml version='1.0' encoding='utf-8'?>
        <!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
        <en-note><div>simple text<br/></div></en-note>
      EOF

      note = Evernote::EDAM::Type::Note.new
      note.content = enml
      
      # could use the same note, I suppose
      note2 = Evernote::EDAM::Type::Note.new
      note2.txt_content = note.txt_content
      
      refute_nil note2.content
      assert note2.content.include?('simple text')
    end

  end

end