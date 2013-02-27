
require_relative './secrets'

require 'evernote/auth'
require 'minitest/autorun'

module EvernoteCLI

  describe Auth do

    it "can log into the sandbox" do

      auth = Auth.new
      auth.login(SANDBOX_USERNAME, SANDBOX_PASSWORD)

    end

    it "can logout"

    it "can login again (after logout)"

    it "remembers that I am logged in"

    it "login username is remembered"

  end

end
