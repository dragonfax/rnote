
require 'rnote/edit'
require 'rnote/find'

include GLI::App


desc 'Describe edit here'
arg_name 'Describe arguments to edit here'
command :edit do |verb|

  verb.command :note do |noun|

    Rnote::Edit.include_set_options(noun)
    Rnote::Edit.include_editor_options(noun)
    Rnote::Find.include_search_options(noun)

    noun.action do |global_options,options,args|

      find = Rnote::Find.new($app.auth,$app.persister)
      edit = Rnote::Edit.new($app.auth)

      note = find.find_note(options.merge(global_options),args)

      edit.edit_action(note,options.merge(global_options))

    end

  end

end


