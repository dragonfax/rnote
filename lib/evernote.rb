
require 'evernote/version.rb'

# verbs
Dir[File.absolute_path(File.dirname(__FILE__)) + '/evernote/cmd/*.rb'].each do |file|
 require file
end

# internal modules
require 'evernote'

require 'evernote_oauth'
require 'mechanize'
require 'evernote/secrets'
require 'yaml'

SANDBOX = true
DUMMY_CALLBACK_URL = 'http://www.evernote.com'

PERSISTENCE_FILE = ENV['HOME'] + '/.rnote_persist'

module EvernoteCLI

  class Persister

    def persist_username(username)
      modify_config do |config|
        config['username'] = username
      end
    end

    def modify_config

      config = {}
      if File.exists?(PERSISTENCE_FILE)
        config = YAML.load_file(PERSISTENCE_FILE)
      end

      result = yield config

      File.unlink(PERSISTENCE_FILE) if File.exists?(PERSISTENCE_FILE)
      File.open(PERSISTENCE_FILE, 'w') do |f|
        f.write config.to_yaml
      end

      result
    end

    def read_config

      config = {}
      if File.exists?(PERSISTENCE_FILE)
        config = YAML.load_file(PERSISTENCE_FILE)
      end

      yield config
    end

    def persist_token(token)
      modify_config do |config|
        config['token'] = token
      end
    end

    def forget_token
      modify_config do |config|
        config.delete('token')
      end
    end

    def forget_username
      modify_config do |config|
        config.delete('username')
      end
    end

    def get_token
      read_config do |config|
        config['token']
      end
    end

    def get_username
      read_config do |config|
        config['username']
      end
    end

    def save_last_search(last_search)
      modify_config do |config|
        config['last_search'] = last_search
      end
    end

  end

  class Auth

    def initialize(persister)
      @persister = persister
    end

    def login(username,password)

      if is_logged_in
        if who == username
          # already logged in (we don't check against service though)
          # if a re-login is truely required, the user can just logout first.
          return
        else
          logout
        end
      end

      # this client isn't authorized, and can only request authorization. no api calls.
      client = EvernoteOAuth::Client.new(
          consumer_key: CONSUMER_KEY,
          consumer_secret: CONSUMER_SECRET,
          sandbox: SANDBOX
      )

      request_token = client.authentication_request_token(:oauth_callback => DUMMY_CALLBACK_URL)
      oauth_verifier = mechanize_login(request_token.authorize_url, username, password)
      access_token = request_token.get_access_token(oauth_verifier: oauth_verifier)
      token = access_token.token

      @persister.persist_username(username)
      @persister.persist_token(token)

    end

    def client
      # not the same as the client used to get the token.
      # this one is fully authorized and can make actual api calls.

      if not is_logged_in
        raise "not logged in"
      end

      @client ||= EvernoteOAuth::Client.new(token: @persister.get_token)

      @client
    end

    def mechanize_login(url, username, password)

      agent = Mechanize.new
      login_page = agent.get(url)
      login_form = login_page.form('login_form')
      login_form.username = username
      login_form.password = password
      accept_page = agent.submit(login_form,login_form.buttons.first)
      accept_form = accept_page.form('oauth_authorize_form')
      # we don't need to go so far as to retrieve the callback url.
      agent.redirect_ok = false
      callback_redirect = agent.submit(accept_form, accept_form.buttons.first)
      response_url = callback_redirect.response['location']
      oauth_verifier = CGI.parse(URI.parse(response_url).query)['oauth_verifier'][0]

      oauth_verifier
    end

    def is_logged_in
      !!@persister.get_token
    end

    def who
      if is_logged_in
        @persister.get_username
      else
        nil
      end
    end


    def logout
      # unfortunately, no way to revoke a token via API
      # TODO perhaps I can redo the oauth, and choose revoke instead of re-accept
      @persister.forget_token
      @persister.forget_username
    end

  end

end
