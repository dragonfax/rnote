
require_relative './secrets'

require 'rnote'
require 'minitest/autorun'

raise unless RNOTE_TESTING_OK

module Rnote

  describe Auth do

    it "can log into the sandbox" do
      
      # note that this test creates a new user token in the sandbox
      # there is no way to revoke these tokesn via just the API.
      # so they will build up over time.

      persister = Persister.new
      auth = Auth.new(persister)
      persister.persist_consumer_key(SANDBOX_CONSUMER_KEY)
      persister.persist_consumer_secret(SANDBOX_CONSUMER_SECRET)
      auth.login_with_password(SANDBOX_USERNAME1, SANDBOX_PASSWORD1)

    end

    it "can logout"

    it "can login again (after logout)"

    it "remembers that I am logged in"

    it "login username is remembered"

  end

end
