
require 'highline/import'

include GLI::App

d 'login to evernote'
long_desc 'Provide credentials and log a user into evernote. The users password is never saved, but an auth token will be.'
command :login do |c|
  
  c.desc "username"
  c.flag [:u,:user,:username]
  
  c.desc "password (if not provided, will ask)"
  c.flag [:p,:pass,:password]
  
  c.desc "developer token, if you wish to forgoe a password."
  c.flag [:d,:'dev-token',:'developer-token']
  
  c.desc "use the sandbox environment in lue of the production evernote system."
  c.default_value false
  c.switch [:s,:sandbox]
  
  c.desc "provide a consumer key, instead of the included one."
  c.flag [:k,:key,:'consumer-key']
  
  c.desc "provide a consumer secret to go along with the consumer key."
  c.flag [:c,:secret,:'consumer-secret']
  
  c.action do |global_options,options,args|
		raise "This command takes no arguments, only options (i.e. --username" unless args.length == 0

    if options[:key]
      $app.persister.persist_consumer_key(options[:key])
    end
    
    if options[:secret]
      $app.persister.persist_consumer_secret(options[:secret])
    end
    
    if options[:d]
      # first check for a dev token
      $app.auth.login_with_developer_token(options[:d],options[:sandbox])
      puts "login successful using developer key"
    else
      # then fall back to using a username and password

      user = options[:user]
      password = options[:password]
      
      if user.nil?
        answer = ask("Enter your username:  ")
        user = answer.chomp
      end
  
      if password.nil?
        answer = ask("Enter your password:  ") { |q| q.echo = 'x' }
        password = answer.chomp
      end
  
      $app.auth.login_with_password(user,password, options[:sandbox])
      
      # test the login with a harmless api call.
      $app.auth.client.user_store.getUser
      
      puts "you are now logged in as '#{$app.auth.who}'"
      
    end

  end
end


