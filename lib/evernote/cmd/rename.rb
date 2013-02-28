include GLI::App
desc 'Describe rename here'
arg_name 'Describe arguments to rename here'
command :rename do |c|
  c.action do |global_options,options,args|
    puts "rename command ran"
  end
end


