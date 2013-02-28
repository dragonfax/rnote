
include GLI::App

desc 'search for notes/tags/notebooks'
arg_name :noun
command :find do |c|

  c.desc "title to search for"
  c.flag :title

  c.action do |global_options,options,args|

    if args[0] == 'note'

      filter = Evernote::EDAM::NoteStore::NoteFilter.new
      if options[:title]
        filter.words = "intitle:\"#{options[:title]}\""
      end
      persister = EvernoteCLI::Persister.new
      client = EvernoteCLI::Auth.new(persister).client
      notes = client.note_store.findNotes(filter,0,1).notes

      #TODO use note metadata instead of notes themselves

      if notes.empty?
        puts "no notes found"
        persister.save_last_search([])
      else
        inc = 1
        last_search = []
        notes.each do |note|
          puts "#{inc}: #{note.title}"
          last_search << { title: note.title, guid: note.guid }
          inc += 1
        end
        persister.save_last_search(last_search)
      end

    else
      raise "unimplemented"
    end

  end
end

