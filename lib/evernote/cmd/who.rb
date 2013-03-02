
include GLI::App

desc 'see which user you are logged in as'
command :who do |c|
  c.action do |global_options,options,args|
    raise unless args.length == 0

    if $app.auth.is_logged_in
      puts $app.auth.who
    else
      puts 'You are not logged in as any user.'
    end

  end
end