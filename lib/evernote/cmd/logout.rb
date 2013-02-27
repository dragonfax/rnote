desc 'log user out of evernote'
command :logout do |c|
  c.action do |global_options,options,args|
    raise unless args.length == 0

    auth = EvernoteCLI::Auth.new(EvernoteCLI::Persister.new)
    auth.logout

  end
end


