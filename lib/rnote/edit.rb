
require 'highline'
require 'nokogiri'

class WaitPidTimeout
  
  # wait in ruby doesn't take a timeout parameter
  # so, join with timeout => wait with timeout
  # launch a thread that does a wait on the pid.
  # then its just a matter of joining that thread, with a timeout.

  def initialize(pid,timeout)
    @pid = pid
    @timeout = timeout
  end

  def wait

    @thread ||= Thread.new(@pid) do |pid|
      Process.waitpid(pid)
    end

    !!@thread.join(@timeout)

  end

end

module Rnote

  class Edit
  
    def initialize(auth)
      @auth = auth
      @converter = Converter.new
    end
  
    def Edit.include_set_options(noun)
      noun.desc 'set the title of the note'
      noun.flag :'set-title'
    end
  
    def Edit.include_editor_options(noun)
      noun.desc 'watch the file while editing and upload changes (you must save the file)'
      noun.default_value true
      noun.switch :watch
  
      noun.desc 'open an interactive editor to modify the note'
      noun.default_value true
      noun.switch :editor
    end
  
    def has_set_options(options)
      options[:'set-title'].nil?
    end
  
    def edit_action(note,options)
  
      attributes = note_to_attributes(note)
  
      if has_set_options(options)
  
        apply_set_options(attributes,options)
  
        if options[:editor]
          editor(note,attributes)
        else
          # if not going to open an editor, then just update immediately
          update_note(note,attributes)
        end
  
      elsif options[:editor]
        # no --set options
        editor(note,attributes)
      else
        raise "you've specified --no-editor but provided not --set options either."
      end
  
    end
  
    def apply_set_options(attributes,options)
      if options[:'set-title']
        attributes[:title] = options[:'set-title']
      end
    end
  
    def note_to_attributes(note)
      {
        :content => @converter.enml_to_raw_markdown(note.content),
        :title => note.title
      }
    end
  
    def update_note(note,attributes)
  
      # read/parse the yaml stream
      attributes = @converter.yaml_stream_to_attributes(yaml_stream)
  
      # create the new note
      note.title = attributes[:title]
      note.content = attributes[:content]
      if note.guid
        # TODO unset unmodified fiels to signal we're not changing them.
        @auth.client.note_store.updateNote(note)
      else
        @auth.client.note_store.createNote(note)
      end
  
    end
  
    def editor(note,attributes)
  
      ENV['EDITOR'] ||= 'vim'
  
      yaml_stream = @converter.attributes_to_yaml_stream(note_attributes)
  
      file = Tempfile.new(['rnote','txt'])
      begin
  
        # fill the tempfile with the yaml stream
        file.write(yaml_stream)
        file.close()
  
        # error detection loop, to retry editing the file
        successful_edit = false
        until successful_edit do
  
          last_mtime = File.mtime(file.path)
  
          # run editor in background
          pid = fork do
            exec(ENV['EDITOR'],file.path)
          end
  
          wwt = WaitPidTimeout.new(pid,1) # 1 second
  
          editor_done = false
          until editor_done do
            if not options[:watch]
              waitpid(pid)
              editor_done = true
            elsif wwt.wait
              # process done
              editor_done = true
            else
              # timeout exceeded
  
              # has the file changed?
              this_mtime = File.mtime(file.path)
              if this_mtime != last_mtime
                update_note_from_file(note,file.path)
                last_mtime = this_mtime
              end
            end
          end
  
          # one last update of the note
          # this time we care if there are errors
          begin
            update_note_from_file(note,file.path)
          rescue Exception => e
  
            puts "There was an error while uploading the note"
            puts e.message
            puts e.backtrace.join("\n    ")
  
            successful_edit = ! agree("Return to editor (otherwise changes will be lost)?")
          else
            successful_edit = true
          end
  
        end # successful edit loop
  
      ensure
        file.unlink
      end
  
    end
  
    def update_note_from_file(note,path)
      yaml_stream = File.open(path,'r').read
      yaml to attributes
      update_note(note,attributes)
    end
  
  
  end

end