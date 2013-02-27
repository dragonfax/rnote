
include GLI::App

desc 'provide evernote credentials'
flag [:u,:user,:username]
flag [:p,:pass,:password]
command :login do |c|
  c.action do |global_options,options,args|
		raise unless args.length == 0
		
  end
end


