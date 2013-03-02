
require 'evernote/version'
require 'evernote/converter'
require 'evernote/persister'
require 'evernote/auth'

# verbs
Dir[File.absolute_path(File.dirname(__FILE__)) + '/evernote/cmd/*.rb'].each do |file|
 require file
end


module EvernoteCLI

  class App

    attr_reader :converter,:persister,:auth

    def initialize
      @converter = Converter.new
      @persister = Persister.new
      @auth = Auth.new(@persister)
    end

    def client
      auth.client
    end

  end

end
