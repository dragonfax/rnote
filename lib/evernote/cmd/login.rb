
include GLI::App

desc 'provide evernote credentials'
command :login do |c|
  c.flag [:u,:user,:username]
  c.flag [:p,:pass,:password]
  c.action do |global_options,options,args|
		raise unless args.length == 0

    if not options[:u]
      puts "Please enter your username>"
      options[:u] = STDIN.gets.chomp
    end

    if not options[:p]
      puts "Please enter your password>"
      options[:p] = STDIN.gets.chomp
    end

    auth = EvernoteCLI::Auth.new(EvernoteCLI::Persister.new)
    auth.login(options[:u],options[:p])
    puts "you are now logged in as '#{auth.who}'"

  end
end


