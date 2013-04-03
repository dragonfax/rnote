
require 'highline'
require 'nokogiri'
require 'tempfile'

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

class Evernote::EDAM::Type::Note
  
  def diff(new_note)
    # returns a Note that represents a diff of the 2, used for client.updateNote()
    
    raise "notes aren't copies of the same note" if self.guid != new_note.guid
    
    contains_diff = false
    
    diff_note = Evernote::EDAM::Type::Note.new
    diff_note.guid = new_note.guid
    
    if self.title != new_note
      contains_diff = true
    end
    # always contains a title
    diff_note.title = new_note.title
    
    if self.content != new_note.content
      contains_diff = true
      diff_note.content = new_note.content
    end
    
    if self.tagNames != new_note.tagNames
      contains_diff = true
      diff_note.tagNames = new_note.tagNames
    end
    
    # we dont' diff tagGuids as we always want to modify tagNames instead.
    # so that the evernote api will handle the tag creation and guids itself.
    
    contains_diff ? diff_note : nil
  end
  
  def deep_dup
    duplicate = self.dup
    duplicate.tagNames = self.tagNames.dup if self.tagNames
    duplicate.tagGuids = self.tagGuids.dup if self.tagGuids
    
    duplicate
  end
  
end

module Rnote

  class Edit
  
    def initialize(auth)
      @auth = auth
      @note = Evernote::EDAM::Type::Note.new
      @note.txt_content = '' # for creating new notes.
      @last_saved_note = Evernote::EDAM::Type::Note.new
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
  
    def Edit.has_set_options(options)
      options[:'set-title']
    end
    
    def options(options)
      @options = options
      @use_editor = options[:editor]
      @watch_editor = options[:watch]
    end
    
    def note(note)
      @note = note
      @last_saved_note = note.deep_dup
    end
  
    def edit_action
      raise if not @note or not @last_saved_note
  
      if Edit.has_set_options(@options)
  
        apply_set_options
  
        if @use_editor
          editor
        else
          # if not going to open an editor, then just update immediately
          save_note
        end
  
      elsif @use_editor
        # no --set options
        editor
      else
        raise "you've specified --no-editor but provided not --set options either."
      end
  
    end
  
    def apply_set_options
      if @options[:'set-title']
        @note.title = @options[:'set-title']
      end
    end
  
    def save_note
      
      diff_note = @last_saved_note.diff(@note)
  
      # only update if necessary
      if diff_note
        
        # create or update
        if diff_note.guid
          @auth.client.note_store.updateNote(diff_note)
        else
          raise "cannot create note with nil content" if diff_note.content.nil?
          new_note = @auth.client.note_store.createNote(diff_note)
          # a few things to copy over
          @note.guid = new_note.guid
        end
        
        # track what the last version we saved was. for diffing
        @last_saved_note = @note.deep_dup
      end
  
    end
    
    # output both forms to a file, and run "diff | less"
    def show_diff(original,altered)
      
      file1 = Tempfile.new('rnote')
      file2 = Tempfile.new('rnote')
      begin
        
        file1.write(original)
        file1.close
        
        file2.write(altered)
        file2.close
        
        system("diff #{file1.path} #{file2.path} | less")
          
        raise "User cnacelled due to lost content." unless agree("Continue editing note?  ")
          
      ensure
        file1.unlink
        file2.unlink
      end
    end
    
    # check if we lose content/formating when converting the note
    # and if so ask the user if they want to continue.
    def check_for_lost_content
      
      converted_content = @note.class.txt_to_enml(@note.class.enml_to_txt(@note.content))
      
      if @note.content != converted_content
        puts "Some content or formatting may be lost in the note due to editing format conversion."
        reply_continue = ask("Continue editing the note? (yes/no/diff) ") { |q|
          q.validate = /\A(y|n|d|q|e|c|yes|no|cancel|quit|exit|diff)\Z/i
          q.responses[:not_valid] = 'Please enter "yes", "no", "diff", or "cancel".'
          q.responses[:ask_on_error] = :question
        }
        
        case reply_continue.downcase
          when 'y'
            # nothing, continue
          when 'yes'
            # nothing, continue
          when 'n'
            raise "User cancelled due to lost content."
          when 'no'
            raise "User cancelled due to lost content."
          when 'cancel'
            raise "User cancelled due to lost content."
          when 'quit'
            raise "User cancelled due to lost content."
          when 'exit'
            raise "User cancelled due to lost content."
          when 'diff'
            show_diff(@note.content,converted_content)
          else
            raise
        end
        
        
      end
    end
    
    def md5(filename)
      # TODO sloppy, switch with non shell command
      `cat #{filename} | md5`.chomp
    end
    
    # has the file changed since the last time we checked.
    def has_file_changed(file)
      
      @last_mtime ||= nil
      @last_md5 ||= nil
      
      this_mtime = File.mtime(file.path)
      this_md5 = md5(file.path)
      
      changed = this_mtime != @last_mtime && this_md5 != @last_md5
      
      @last_mtime = this_mtime
      @last_md5 = this_md5
      
      changed
    end
    
  
    def editor
  
      ENV['EDITOR'] ||= 'vim'
      
      check_for_lost_content
  
      file = Tempfile.new(['rnote','.txt'])
      begin
  
        # fill the tempfile with the yaml stream
        yaml_stream = @note.yaml_stream
        file.write(yaml_stream)
        file.close()
  
        # error detection loop, to retry editing the file
        successful_edit = false
        until successful_edit do
  
          has_file_changed(file) # initialize the file change tracking.
  
          # run editor in background
          pid = fork do
            exec(ENV['EDITOR'],file.path)
          end
  
          wwt = WaitPidTimeout.new(pid,1) # 1 second
  
          editor_done = false
          until editor_done do
            if not @watch_editor
              Process.waitpid(pid)
              editor_done = true
            elsif wwt.wait
              # process done
              editor_done = true
            else
              # timeout exceeded
  
              # has the file changed?
              if has_file_changed(file)
                # protect the running editor from our failures.
                begin
                  update_note_from_file(file.path)
                rescue Exception => e
                  $stderr.puts "rnote: an error occured while updating the note: #{e.message}"
                end
              end
            end
          end
  
          # one last update of the note
          # this time we care if there are errors
          if has_file_changed(file)
            begin
              update_note_from_file(file.path)
            rescue Exception => e
    
              puts "There was an error while uploading the note"
              puts e.message
              puts e.backtrace.join("\n    ")
    
              successful_edit = ! agree("Return to editor? (otherwise changes will be lost)  ")
            else
              successful_edit = true
            end
          else
            # no changes to file, no need to save.
            successful_edit = true
          end
  
        end # successful edit loop
  
      ensure
        file.unlink
      end
  
    end
  
    def update_note_from_file(path)
      
      yaml_stream = File.open(path,'r').read
      @note.yaml_stream = yaml_stream
      
      save_note
    end
  
  
  end

end