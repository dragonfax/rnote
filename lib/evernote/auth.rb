
require 'evernote_oauth'
require 'mechanize'
require 'evernote/secrets'

SANDBOX = true
DUMMY_CALLBACK_URL = 'http://www.evernote.com'

module EvernoteCLI

  class Auth

    def login(username,password)

      client = EvernoteOAuth::Client.new(
          consumer_key: CONSUMER_KEY,
          consumer_secret: CONSUMER_SECRET,
          sandbox: SANDBOX
      )

      request_token = client.authentication_request_token(:oauth_callback => DUMMY_CALLBACK_URL)

      oauth_verifier = mechanize_login(request_token.authorize_url, username, password)

      raise unless oauth_verifier

      access_token = request_token.get_access_token(oauth_verifier: oauth_verifier)

      token = access_token.token

      persist_username(username)
      persist_token(token)

      client2 = EvernoteOAuth::Client.new(token: token)
      note_store = client2.note_store
      notebooks = note_store.listNotebooks(token)

      puts "\n",notebooks[0].name,"\n"




    end

    def persist_username(username)
      puts "username #{username}"
    end

    def persist_token(token)
      puts "token #{token}"
    end

    def mechanize_login(url, username, password)


      agent = Mechanize.new
      page = agent.get(url)
      form = page.form('login_form')
      form.username = username
      form.password = password
      page2 = agent.submit(form,form.buttons.first)
      form2 = page2.form('oauth_authorize_form')
      agent.redirect_ok = false
      page3 = agent.submit(form2, form2.buttons.first)
      response_url = page3.response['location']
      oauth_verifier = CGI.parse(URI.parse(response_url).query)['oauth_verifier'][0]

      oauth_verifier
    end

  end

end