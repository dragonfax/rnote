
require 'rnote/noun/note/find'

include GLI::App


d 'search for notes'
long_desc <<EOF
Provide a query and find matching notes.   Provides a short summary of each note in the result.

You can run this command before running other commands that require a note to be selected, such as 'edit', or 'remove'. And then specify the result number on the next command line.
EOF
command :find do |verb|

  verb.desc 'find notes'
  verb.command :note do |noun|

    Rnote::Find.include_search_options(noun)

    noun.action do |global_options,options,args|
      
      find = Rnote::Find.new($app.auth,$app.persister)
      find.find_cmd(options.merge(global_options),args)

    end
  end
  
  verb.default_command :note
end

