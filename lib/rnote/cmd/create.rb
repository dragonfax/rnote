
require 'gli'

require 'rnote/edit'

include GLI::App


d 'create a new note'
long_desc 'create a new note and, optionally, launch an editor to provide its content'
command :create do |verb|

  d 'create a new note'
  verb.command :note do |noun|

    Rnote::Edit.include_set_options(noun)
    Rnote::Edit.include_editor_options(noun)

    noun.action do |global_options,options,args|

      if args.length > 0
        raise "create doesn't take a search query"
      end

      edit = Rnote::Edit.new($app.auth)
      edit.options(options.merge(global_options))
      edit.edit_action


    end
  end
  
  verb.default_command :note
end
