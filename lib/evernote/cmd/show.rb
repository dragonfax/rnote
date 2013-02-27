desc 'Describe show here'
arg_name 'Describe arguments to show here'
command :show do |c|
  c.action do |global_options,options,args|
    puts "show command ran"
  end
end


