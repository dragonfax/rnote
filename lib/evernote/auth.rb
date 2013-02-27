
require 'evernote_oauth'
require 'mechanize'
require 'evernote/secrets'

SANDBOX = true
DUMMY_CALLBACK_URL = 'https://home.jason-stillwell.com'

module EvernoteCLI

  class Auth

    def login(username,password)

      client = EvernoteOAuth::Client.new(
          consumer_key: CONSUMER_KEY,
          consumer_secret: CONSUMER_SECRET,
          sandbox: SANDBOX
      )

      request_token = client.authentication_request_token(:oauth_callback => DUMMY_CALLBACK_URL)
      puts "\n#{request_token.authorize_url}\n"

=begin
      oauth_verifier = mechanize_login(request_token.authorize_url, username, password)

      access_token = request_token.get_access_token(oauth_verifier: oauth_verifier)

      token = access_token.token

      persist_username(username)
      persist_token(token)
=end

    end

    def persist_username(username)
      puts "username #{username}"
    end

    def persist_token(token)
      puts "token #{token}"
    end

    def mechanize_login(url, username, password)

=begin
      mech = Mechanize.new

      mech.get(url) do |login_page|

        fill in username
        fill in password
        approve_page = click signin

        redirect = approve_page.click approve

        redirect.find oauth_verifier in redirect history

        oauth_verifier

      end

=end

    end

  end

end