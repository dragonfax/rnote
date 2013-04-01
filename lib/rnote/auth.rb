
require 'mechanize'
require 'evernote_oauth'
require 'rnote/persister'

DUMMY_CALLBACK_URL = 'http://www.evernote.com'

module Rnote

  class Auth

    def initialize(persister=Persister.new)
      @persister = persister
    end
    
    def login_with_developer_token(developer_token,sandbox)
      if is_logged_in
        if @persister.get_developer_token == developer_token
          return
        else
          logout
        end
      end
      @persister.persist_developer_token(developer_token)
      @persister.persist_sandbox(sandbox)
    end

    def login_with_password(username,password,sandbox)
      
      if is_logged_in
        if who == username
          # already logged in (we don't check against service though)
          # if a re-login is truely required, the user can just logout first.
          return
        else
          logout
        end
      end

      ## Consumer Key and Secret provided in published gem.
      #
      # we'll use these if the user doesn't provide their own
      # we do this check here, instead of in Persister,
      # so we can verify this is only used in production, not sandbox.
      #

      consumer_key = @persister.get_consumer_key || ( ! sandbox && PRODUCTION_CONSUMER_KEY )
      raise 'no consumer key to use, please provide one.' unless consumer_key
      consumer_secret = @persister.get_consumer_secret || ( ! sandbox && PRODUCTION_CONSUMER_SECRET )
      raise 'no consumer secret to use, please provide one.' unless consumer_secret
      
      ## Get a user key using these crednetials
      
      # this client isn't authorized, and can only request authorization. no api calls.
      auth_client = EvernoteOAuth::Client.new(
          consumer_key: consumer_key,
          consumer_secret: consumer_secret,
          sandbox: sandbox
      )

      request_token = auth_client.request_token(:oauth_callback => DUMMY_CALLBACK_URL)
      oauth_verifier = mechanize_login(request_token.authorize_url, username, password)
      access_token = request_token.get_access_token(oauth_verifier: oauth_verifier)
      user_token = access_token.token

      @persister.persist_username(username)
      @persister.persist_user_token(user_token)
      @persister.persist_sandbox(sandbox)

    end

    def client
      # not the same as the client used to get the token.
      # this one is fully authorized and can make actual api calls.

      if not is_logged_in
        raise "not logged in"
      end
      
      token = @persister.get_user_token || @persister.get_developer_token
      
      @client ||= EvernoteOAuth::Client.new(token: token, sandbox: @persister.get_sandbox)

      @client
    end
    
    def note_store
      client.note_store
    end

    def mechanize_login(url, username, password)

      agent = Mechanize.new
      login_page = agent.get(url)
      login_form = login_page.form('login_form')
      raise unless login_form
      login_form.username = username
      login_form.password = password
      accept_page = agent.submit(login_form,login_form.buttons.first)

      if accept_page.form('login_form')
        # sent us back to the login page
        raise "bad username/password"
      elsif not accept_page.form('oauth_authorize_form')
        raise "failed to login"
      end

      accept_form = accept_page.form('oauth_authorize_form')
      # we don't need to go so far as to retrieve the callback url.
      agent.redirect_ok = false
      callback_redirect = agent.submit(accept_form, accept_form.buttons.first)
      response_url = callback_redirect.response['location']
      oauth_verifier = CGI.parse(URI.parse(response_url).query)['oauth_verifier'][0]

      oauth_verifier
    end

    def is_logged_in
      @persister.get_user_token or @persister.get_developer_token
    end

    def who
      if is_logged_in
        @persister.get_username or @persister.get_developer_token
      else
        nil
      end
    end


    def logout
      # unfortunately, no way to revoke a token via API
      # TODO perhaps I can redo the oauth, and choose revoke instead of re-accept
      @persister.forget_user_token
      @persister.forget_username
      @persister.forget_developer_token
      @persister.forget_sandbox
    end

  end

end
