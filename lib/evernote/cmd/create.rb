
require 'gli'

require 'evernote/edit'

include GLI::App


desc 'create a note and launch the editor for it'
command :create do |verb|
  verb.command :note do |noun|


    EvernoteCLI::Edit.include_set_options(noun)
    EvernoteCLI::Edit.include_editor_options(noun)

    noun.action do |global_options,options,args|

      if args.length > 0
        raise "create doesn't take a search query"
      end

      note = Evernote::EDAM::Type::Note.new

      edit = EvernoteCLI::Edit.new($app.auth)
      edit.edit_action(note,options)


    end
  end
end
