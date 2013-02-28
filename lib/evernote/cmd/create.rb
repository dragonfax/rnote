
include GLI::App

desc 'create a note and launch the editor for it'
command :create do |verb|
  verb.command :note do |noun|

    noun.flag :title

    noun.default_value true
    noun.switch 'edit'

    noun.action do |global_options,options,args|

      client = EvernoteCLI::Auth.new( persister = EvernoteCLI::Persister.new ).client

      content = ''

      if options[:edit]

        if not ENV['EDITOR']
          raise "no EDITOR"
        end

        file = Tempfile.new(['evernote','txt'])
        begin
          # content = client.note_store.get_note(notes.first.guid,true,false,false,false)
          # f.write(content)
          file.close()

          system(ENV['EDITOR'],file.path)

          # wait for the editor

          content = File.open(file.path,'r').read
        ensure
          file.unlink
        end
      end

      enml = <<EOF
<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note>
<pre>#{content}</pre>
</en-note>
EOF

      # verify_valid_enml(enml)

      note = Evernote::EDAM::Type::Note.new
      note.title = options[:title]
      note.content = enml
      begin
        client.note_store.createNote(note)
      rescue Evernote::EDAM::Error::EDAMUserException => e
        raise e.parameter
      end


    end
  end
end

require 'libxml'

include LibXML

ENML_DTD_FILE = File.dirname(__FILE__) + '/../enml2.dtd'
raise unless File.exists?(ENML_DTD_FILE)

def verify_valid_enml(content)

  puts "validating enml"

  dtd = XML::Dtd.new(File.read(ENML_DTD_FILE))
  doc = XML::Document.string(content)
  doc.validate(dtd)

  puts "completed validating enml"

end

