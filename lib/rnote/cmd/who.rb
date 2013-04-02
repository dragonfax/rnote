
include GLI::App

d 'which user is logged in'
long_desc 'see what username is logged in, or if your using a developer token instead of a username.'
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