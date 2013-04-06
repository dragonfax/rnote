

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

# load optional production consumer key
begin
  require_relative 'rnote/consumer'
rescue LoadError
  # ignore
  PRODUCTION_CONSUMER_KEY = nil
  PRODUCTION_CONSUMER_SECRET = nil
end

require 'rnote/version'
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

module EDAMErrors
  
  def error_code_string
    Evernote::EDAM::Error::EDAMErrorCode.constants.select { |constant_sym|
      Evernote::EDAM::Error::EDAMErrorCode.const_get(constant_sym) == self.errorCode
    }.first.to_s
  end
  
end

class Evernote::EDAM::Error::EDAMSystemException
  
  include EDAMErrors
  
  def error_message
    "#{self.error_code_string}(#{self.errorCode}: #{self.message})"
  end
  
end

class Evernote::EDAM::Error::EDAMUserException

  include EDAMErrors
 
  def error_message
    "#{self.error_code_string}(#{self.errorCode}): #{self.parameter}"
  end
  
end
