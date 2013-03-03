
include GLI::App

desc 'provide rnote credentials'
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

    $app.auth.login(options[:u],options[:p])
    puts "you are now logged in as '#{$app.auth.who}'"

  end
end


