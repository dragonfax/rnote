
require 'evernote/edit'
require 'evernote/find'

include GLI::App


desc 'Describe edit here'
arg_name 'Describe arguments to edit here'
command :edit do |verb|

  verb.command :note do |noun|

    EvernoteCLI::Edit.include_set_options(noun)
    EvernoteCLI::Edit.include_editor_options(noun)
    EvernoteCLI::Find.include_search_options(noun)

    noun.action do |global_options,options,args|

      find = EvernoteCLI::Find.new(app.auth,app.persister)
      edit = EvernoteCLI::Edit.new(app.auth)

      note = find.find_note(options,args)

      edit.edit_action(note,options)

    end

  end

end


