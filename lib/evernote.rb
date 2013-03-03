
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
