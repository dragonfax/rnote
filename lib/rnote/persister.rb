
require 'yaml'

PERSISTENCE_FILE = ENV['HOME'] + '/.rnote_persist'

module Rnote
  class Persister

    def persist_username(username)
      modify_config do |config|
        config['username'] = username
      end
    end

    def modify_config

      config = {}
      if File.exists?(PERSISTENCE_FILE)
        config = YAML.load_file(PERSISTENCE_FILE)
      end

      result = yield config

      File.unlink(PERSISTENCE_FILE) if File.exists?(PERSISTENCE_FILE)
      File.open(PERSISTENCE_FILE, 'w') do |f|
        f.write config.to_yaml
      end

      result
    end

    def read_config

      config = {}
      if File.exists?(PERSISTENCE_FILE)
        config = YAML.load_file(PERSISTENCE_FILE)
      end

      yield config
    end

    def persist_token(token)
      modify_config do |config|
        config['token'] = token
      end
    end

    def forget_token
      modify_config do |config|
        config.delete('token')
      end
    end

    def forget_username
      modify_config do |config|
        config.delete('username')
      end
    end

    def get_token
      read_config do |config|
        config['token']
      end
    end

    def get_username
      read_config do |config|
        config['username']
      end
    end

    def save_last_search(notes)
      modify_config do |config|
        config['last_search'] = notes.map do |note|
          # convert the note to something more serializable.
          # tags = @auth.client.note_store.getNoteTagNames(note.guid)
          # brief = Rnote.enml_to_markdown(@auth.client.note_store.getNoteContent(note.guid))[0..30]
          { title: note.title, guid: note.guid, tagNames: note.tagNames }
        end
      end
    end
    
    def get_last_search
      read_config do |config|
        config['last_search'] || []
      end.map do |note_hash|
        note = Evernote::EDAM::Type::Note.new
        note.title = note_hash[:title]
        note.guid = note_hash[:guid]
        note.tagNames = note_hash[:tagNames]
        note.cached = true
        
        note
      end
    end

  end

end
