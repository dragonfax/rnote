
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

    def save_last_search_guids(guids)
      modify_config do |config|
        config['last_search'] = guids
      end
    end
    
    def get_last_search_guids
      read_config do |config|
        config['last_search'] || []
      end
    end

  end

end
