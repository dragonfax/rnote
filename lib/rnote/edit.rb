
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
      options[:'set-title']
    end
  
    def edit_action(note,options)
  
      if has_set_options(options)
  
        apply_set_options(note,options)
  
        if options[:editor]
          editor(note)
        else
          # if not going to open an editor, then just update immediately
          save_note(note)
        end
  
      elsif options[:editor]
        # no --set options
        editor(note)
      else
        raise "you've specified --no-editor but provided not --set options either."
      end
  
    end
  
    def apply_set_options(note,options)
      if options[:'set-title']
        note.title = options[:'set-title']
      end
    end
  
    def save_note(note)
  
      if note.guid
        @auth.client.note_store.updateNote(note)
      else
        new_note = @auth.client.note_store.createNote(note)
        note.guid = new_note.guid
      end
  
    end
  
    def editor(note)
  
      ENV['EDITOR'] ||= 'vim'
  
      file = Tempfile.new(['rnote','txt'])
      begin
  
        # fill the tempfile with the yaml stream
        yaml_stream = note.to_yaml_stream
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
      updated_note = Evernote::EDAM::Type::Note.from_yaml_stream
      note.title = updated_note.title
      note.content = updated_note.content
      note.tagNames = updated_note.tagNames
      
      save_note(note)
    end
  
  
  end

end