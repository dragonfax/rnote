
include GLI::App

desc 'log user out of rnote'
command :logout do |c|
  c.action do |global_options,options,args|
    raise unless args.length == 0

    $app.auth.logout

  end
end


