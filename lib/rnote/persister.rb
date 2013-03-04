
require 'yaml'

RNOTE_DIR = ENV['HOME'] + '/.rnote'
AUTH_FILE = RNOTE_DIR + '/auth'
SEARCH_FILE = RNOTE_DIR + '/search_cache'
SETTINGS_FILE = RNOTE_DIR + '/rnoterc'

=begin

These files are always YAML.

You can create and modify the rc file, at will.

You shouldn't touch the auth or search_cache.
These are auto-generated

=end


if not File.exists?(RNOTE_DIR)
  Dir.mkdir(RNOTE_DIR)
end

module Rnote
  
  module ConfigFile
    
    def modify_config
      
      raise if self.methods.include?(:readonly) and readonly
      
      # TODO lock the file through this process

      config = {}
      if File.exists?(@config_file)
        config = YAML.load_file(@config_file)
      end

      result = yield config

      # TODO unlink is unnecessary, just truncate the file and write the new content.
      #      this will keep permissions and lock
      File.unlink(@config_file) if File.exists?(@config_file)
      File.open(@config_file, 'w') do |f|
        f.write header if self.methods.include? :header
        f.write config.to_yaml
        after_vivify if self.methods.include? :after_vivify
      end

      result
    end

    def read_config

      config = {}
      if File.exists?(@config_file)
        config = YAML.load_file(@config_file)
      end

      yield config
    end
    
  end
  
  class AuthCache
    
    include ConfigFile
    
    def initialize
      @config_file = AUTH_FILE
    end
    
    def header
      <<EOF
      
#
# This file is auto-generated and shouldn't be edited by hand
#
# deleting this file is akin to logging out.
#

EOF
    end
    
    def after_vivify
      FileUtils.chmod 0600, AUTH_FILE
    end
    
    def persist_username(username)
      modify_config do |config|
        config['username'] = username
      end
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
    
  end
  
  class SearchCache
    
    include ConfigFile
    
    def initialize
      @config_file = SEARCH_FILE
    end
    
    def header
      <<EOF
      
#
# This file is auto-generated and shouldn't be edited by hand
#
# feel free to delete this file.
#

EOF
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
  
  class Settings 
    include ConfigFile
    
    def initialize
      @config_file = SETTINGS_FILE
    end
    
    def readonly
      true
    end
     
    def developer_token
      read_config do |config|
        config['developer_token']
      end
    end
    
    def sandbox
      read_config do |config|
        if config['sandbox'].nil?
          # default to true, just incase
          false
        else
          config['sandbox']
        end
      end
    end
    
  end
  
  class Persister
    
    def initialize()
      @auth_cache = AuthCache.new
      @search_cache = SearchCache.new
      @settings = Settings.new
    end
    
    def persist_username(*args)
      @auth_cache.persist_username(*args)
    end
    
    def persist_token(*args)
      @auth_cache.persist_token(*args)
    end
    
    def forget_token
      @auth_cache.forget_token
    end
    
    def forget_username
      @auth_cache.forget_username
    end
    
    def get_token
      if @settings.developer_token
        @settings.developer_token
      else
        @auth_cache.get_token
      end
    end
    
    def get_username
      @auth_cache.get_username
    end

    def get_last_search_guids
      @search_cache.get_last_search_guids
    end
          
    def save_last_search_guids(*args)
      @search_cache.save_last_search_guids(*args)
    end
    
    def sandbox
      @settings.sandbox
    end
  end

end
