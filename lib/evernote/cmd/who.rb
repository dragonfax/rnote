desc 'see which user you are logged in as'
command :who do |c|
  c.action do |global_options,options,args|
    raise unless args.length == 0

    auth = EvernoteCLI::Auth.new(EvernoteCLI::Persister.new)
    if auth.is_logged_in
      puts auth.who
    else
      puts 'You are not logged in as any user.'
    end

  end
end