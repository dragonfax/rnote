

# environment detection
begin
  # this file only exists in development
  # its not included in the gem, 
  # and thus not found in production (the installed gem)
  require_relative 'rnote/environment'
rescue LoadError
  # production environment
  # should only happen in the installed gem.
  RNOTE_HOME ||= ENV['HOME'] + '/.rnote' 
  RNOTE_TESTING_OK = false
  RNOTE_SANDBOX_ONLY = false
end

require 'rnote/version'
require 'rnote/converter'
require 'rnote/persister'
require 'rnote/auth'

# verbs
Dir[File.absolute_path(File.dirname(__FILE__)) + '/rnote/cmd/*.rb'].each do |file|
 require file
end


module Rnote

  class App

    attr_reader :persister,:auth

    def initialize
      @persister = Persister.new
      @auth = Auth.new(@persister)
    end

    def client
      auth.client
    end

  end

end


