
include GLI::App

desc 'provide evernote credentials'
flag [:u,:user,:username]
flag [:p,:pass,:password]
command :login do |c|
  c.action do |global_options,options,args|
		raise unless args.length == 0
		
		if not options[:username]
			ask for username
		end

		if not options[:password]
			ask for password
		end

		do auth

  end
end


