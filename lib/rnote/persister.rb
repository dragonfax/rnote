
require 'yaml'

AUTH_FILE = RNOTE_HOME + '/auth'
SEARCH_FILE = RNOTE_HOME + '/search_cache'

=begin

These files are always YAML.

You can create and modify the rc file, at will.

You shouldn't touch the auth or search_cache.
These are auto-generated

=end


if not File.exists?(RNOTE_HOME)
  Dir.mkdir(RNOTE_HOME)
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
        config[:username] = username
      end
    end


    def persist_user_token(user_token)
      modify_config do |config|
        config[:user_token] = user_token
      end
    end
    
    def persist_developer_token(developer_token)
      modify_config do |config|
        config[:developer_token] = developer_token
      end
    end

    def forget_user_token
      modify_config do |config|
        config.delete(:user_token)
      end
    end

    def forget_username
      modify_config do |config|
        config.delete(:username)
      end
    end
    
    def forget_developer_token
      modify_config do |config|
        config.delete(:developer_token)
      end
    end

    def get_user_token
      read_config do |config|
        config[:user_token]
      end
    end

    def get_username
      read_config do |config|
        config[:username]
      end
    end
    
    def get_developer_token
      read_config do |config|
        config[:developer_token]
      end
    end
    
    def get_sandbox
      read_config do |config|
        if config[:sandbox].nil?
          # default to true
          true
        else
          config[:sandbox]
        end
      end
    end
    
    def get_consumer_key
      read_config do |config|
        if config[:consumer_key].nil?
          raise "no consumer key saved"
        else
          config[:consumer_key]
        end
      end
    end
    
    def get_consumer_secret
      read_config do |config|
        if config[:consumer_secret].nil?
          raise "noc consumer secret saved"
        else
          config[:consumer_secret]
        end
      end
    end
    
    def persist_sandbox(sandbox)
      raise if ! sandbox and RNOTE_SANDBOX_ONLY
      modify_config do |config|
        config[:sandbox] = sandbox
      end
    end
    
    def persist_consumer_key(consumer_key)
      modify_config do|config|
        config[:consumer_key] = consumer_key
      end
    end
    
    def persist_consumer_secret(consumer_secret)
      modify_config do |config|
        config[:consumer_secret] = consumer_secret
      end
    end
    
    def forget_sandbox
      modify_config do |config|
        config.delete(:sandbox)
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
        config[:last_search] = guids
      end
    end
    
    def get_last_search_guids
      read_config do |config|
        config[:last_search] || []
      end
    end
    
  end
  
  class Persister
    
    def initialize()
      @auth_cache = AuthCache.new
      @search_cache = SearchCache.new
    end
    
    def method_missing(method,*args)
      if @auth_cache.respond_to?(method)
        @auth_cache.method(method).call(*args)
      elsif @search_cache.respond_to?(method)
        @search_cache.method(method).class(*args)
      else
        super
      end
    end

  end

end
