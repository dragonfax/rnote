
require 'gli'

include GLI::App

desc 'create a note and launch the editor for it'
command :create do |verb|
  verb.command :note do |noun|

    noun.flag :title

    noun.default_value true
    noun.switch 'edit'

    noun.action do |global_options,options,args|

      client = EvernoteCLI::Auth.new( persister = EvernoteCLI::Persister.new ).client
      converter = EvernoteCLI::Converter.new

      yaml_stream = nil

      begin

        # create the yaml stream
        # Note: in this command it just creates an empty yaml_stream, but the format is important.
        note_attributes = {
          :content => converter.raw_markdown_to_enml(''), # empty enml document
          :title => ''
        }
        if options[:title]
          note_attributes[:title] = options[:title]
        end
        yaml_stream = converter.attributes_to_yaml_stream(note_attributes)

      end

      ## using an Editor for note content

      if options[:edit]

        if not ENV['EDITOR']
          raise "no EDITOR"
        end

        file = Tempfile.new(['evernote','txt'])
        begin

          # fill the tempfile with the yaml stream
          file.write(yaml_stream)
          file.close()

          system(ENV['EDITOR'],file.path)
          # wait for the editor

          # read the yaml stream from the temp file.
          # Note: can't reopen a file in ruby.
          yaml_stream = File.open(file.path,'r').read
        ensure
          file.unlink
        end
      end

      begin

        # read/parse the yaml stream
        attributes = converter.yaml_stream_to_attributes(yaml_stream)

        # create the new note
        note = Evernote::EDAM::Type::Note.new
        note.title = attributes[:title]
        note.content = attributes[:content]
        begin
          client.note_store.createNote(note)
        rescue Evernote::EDAM::Error::EDAMUserException => e
          raise e.parameter
        end

      end

    end
  end
end
