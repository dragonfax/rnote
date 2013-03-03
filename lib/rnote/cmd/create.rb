
require 'gli'

require 'rnote/edit'

include GLI::App


desc 'create a note and launch the editor for it'
command :create do |verb|
  verb.command :note do |noun|


    Rnote::Edit.include_set_options(noun)
    Rnote::Edit.include_editor_options(noun)

    noun.action do |global_options,options,args|

      if args.length > 0
        raise "create doesn't take a search query"
      end

      note = Evernote::EDAM::Type::Note.new

      edit = Rnote::Edit.new($app.auth)
      edit.edit_action(note,options)


    end
  end
end