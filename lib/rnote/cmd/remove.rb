include GLI::App
desc 'Describe remove here'
arg_name 'Describe arguments to remove here'
command :remove do |c|
  c.action do |global_options,options,args|
    puts "remove command ran"
  end
end


