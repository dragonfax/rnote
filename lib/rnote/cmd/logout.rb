
include GLI::App

=begin

only drops the token.
there is no way to ask evernote to revoke the token, from an api.

will forget about the user,password or developer key.
but won't forget about a consumer key, as that by itself is not considered a login.

=end

d 'logout user'
long_desc "Log a user out of evernote. This forgets any credential information that may have been cached. currently this does not revoke the token though. It simply forgets what the token was."
command :logout do |c|
  c.action do |global_options,options,args|
    raise unless args.length == 0

    $app.auth.logout

  end
end


