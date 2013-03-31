
require 'rnote/find'

include GLI::App


desc 'output notes to the console'
command :show do |verb|

  verb.desc 'find and output notes to the console'
  verb.command :note do |noun|

    Rnote::Find.include_search_options(noun)
    
    noun.desc 'include title in the output'
    noun.default_value true
    noun.switch :'include-title', :'inc-title'

    noun.action do |global_options,options,args|

      find = Rnote::Find.new($app.auth,$app.persister)
      note = find.find_note(options.merge(global_options),args)
      
      content = note.txt_content
      
      puts note.title if options[:'include-title']
      puts content

    end

  end
end



