require 'aruba/cucumber'
require_relative '../../test/integration/secrets'
require 'rnote'
require 'minitest/unit'

raise unless RNOTE_TESTING_OK

ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"
LIB_DIR = File.join(File.expand_path(File.dirname(__FILE__)),'..','..','lib')

ENV['GLI_DEBUG'] = 'true'

Before do
  # Using "announce" causes massive warnings on 1.9.2
  @puts = true
  @original_rubylib = ENV['RUBYLIB']
  ENV['RUBYLIB'] = LIB_DIR + File::PATH_SEPARATOR + ENV['RUBYLIB'].to_s

  @aruba_timeout_seconds = 10
end

After do
  ENV['RUBYLIB'] = @original_rubylib
end

module Rnote
  
  class ApiHelper
    
    include MiniTest::Assertions

    def initialize
      @persister = Rnote::Persister.new
      @auth = Rnote::Auth.new(@persister)
    end

    def client
      @auth.client
    end

  end

end

World do
  Rnote::ApiHelper.new
end
