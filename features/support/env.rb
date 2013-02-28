require 'aruba/cucumber'
require_relative '../../test/integration/secrets'
require 'evernote'

ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"
LIB_DIR = File.join(File.expand_path(File.dirname(__FILE__)),'..','..','lib')

Before do
  # Using "announce" causes massive warnings on 1.9.2
  @puts = true
  @original_rubylib = ENV['RUBYLIB']
  ENV['RUBYLIB'] = LIB_DIR + File::PATH_SEPARATOR + ENV['RUBYLIB'].to_s

  @aruba_timeout_seconds = 5
end

After do
  ENV['RUBYLIB'] = @original_rubylib
end

module EvernoteCLI

  module Secrets

    def username
      SANDBOX_USERNAME
    end

    def password
      SANDBOX_PASSWORD
    end

  end

  class ApiHelper

    def initialize
      @auth = EvernoteCLI::Auth.new(EvernoteCLI::Persister.new)
    end

    def client
      @auth.client
    end

  end

end

World(EvernoteCLI::Secrets)

World do
  EvernoteCLI::ApiHelper.new
end
