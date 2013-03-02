
require 'evernote/find'

include GLI::App


desc 'output notes to the console'
command :show do |verb|

  verb.desc 'find and output notes to the console'
  verb.command :note do |noun|

    EvernoteCLI::Find.include_search_options(noun)

    noun.action do |global_options,options,args|

      find = EvernoteCLI::Find.new(app.auth,app.persister)
      note = find.find_note(options,args)
      content = app.client.note_store.getNoteContent(note.guid)
      puts content

    end

  end
end



