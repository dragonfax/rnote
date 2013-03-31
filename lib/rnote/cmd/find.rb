
require 'rnote/find'

include GLI::App


desc 'search for notes/tags/notebooks'
command :find do |verb|

  verb.command :note do |noun|

    Rnote::Find.include_search_options(noun)

    noun.action do |global_options,options,args|
      
      find = Rnote::Find.new($app.auth,$app.persister)
      find.find_cmd(options.merge(global_options),args)

    end
  end
  
  verb.default_command :note
end

