desc 'Describe edit here'
arg_name 'Describe arguments to edit here'
command :edit do |c|
  c.action do |global_options,options,args|
    puts "edit command ran"
  end
end


