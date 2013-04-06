
require 'rnote/noun/note/find'

include GLI::App


d 'show note content'
long_desc "output a note's content to the console."
command :show do |verb|

  verb.desc "output a note's content"
  verb.command :note do |noun|

    Rnote::Find.include_search_options(noun)
    
    noun.desc 'include title in the output'
    noun.default_value true
    noun.switch :'include-title', :'inc-title', :'output-title', :'show-title'
    
    noun.desc 'which format to output? (txt or enml)'
    noun.default_value 'txt'
    noun.flag :format

    noun.action do |global_options,options,args|

      find = Rnote::Find.new($app.auth,$app.persister)
      note = find.find_note(options.merge(global_options),args)
      
      
      puts note.title if options[:'include-title']
      if options[:format] == 'txt'
        puts note.txt_content
      elsif options[:format] == 'enml'
        puts note.content
      else
        raise "Unknown outoput format specified."
      end

    end

  end
  
  verb.default_command :note
end



