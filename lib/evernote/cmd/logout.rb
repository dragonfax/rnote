desc 'Describe logout here'
arg_name 'Describe arguments to logout here'
command :logout do |c|
  c.action do |global_options,options,args|
    puts "logout command ran"
  end
end


