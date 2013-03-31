
require_relative './secrets'

require 'rnote'
require 'minitest/autorun'

module Rnote

  describe Auth do

    it "can log into the sandbox" do

      auth = Auth.new
      auth.login(SANDBOX_USERNAME1, SANDBOX_PASSWORD1)

    end

    it "can logout"

    it "can login again (after logout)"

    it "remembers that I am logged in"

    it "login username is remembered"

  end

end
