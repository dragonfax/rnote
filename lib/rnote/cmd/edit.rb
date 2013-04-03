
require 'rnote/edit'
require 'rnote/find'

include GLI::App

# TODO why doesn't 'desc' work here instead of 'd'. What is over-riding it?
d 'edit/update a note'
long_desc 'Edit/update an existing note, usually by launching an editor.'
command :edit do |verb|

  verb.desc "edit a note"

  verb.command :note do |noun|

    Rnote::Edit.include_set_options(noun)
    Rnote::Edit.include_editor_options(noun)
    Rnote::Find.include_search_options(noun)

    noun.action do |global_options,options,args|

      find = Rnote::Find.new($app.auth,$app.persister)
      note = find.find_note(options.merge(global_options),args)
      
      edit = Rnote::Edit.new($app.auth)
      edit.options(options.merge(global_options))
      edit.note(note)
      edit.edit_action

    end

  end
  
  verb.default_command :note

end


