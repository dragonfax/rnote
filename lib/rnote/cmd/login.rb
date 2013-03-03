
require 'highline/import'

include GLI::App

desc 'provide rnote credentials'
command :login do |c|
  
  c.desc "username"
  c.flag [:u,:user,:username]
  
  c.desc "password (if not provided, will ask)"
  c.flag [:p,:pass,:password]
  
  c.action do |global_options,options,args|
		raise unless args.length == 0

    if not options[:u]
      answer = ask("Enter your username:  ")
      options[:u] = answer
    end

    if not options[:p]
      answer = ask("Enter your password:  ") { |q| q.echo = 'x' }
      options[:p] = answer
    end

    $app.auth.login(options[:u],options[:p])
    puts "you are now logged in as '#{$app.auth.who}'"

  end
end


