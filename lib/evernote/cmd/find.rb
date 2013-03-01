
include GLI::App

desc 'search for notes/tags/notebooks'
arg_name :noun
command :find do |verb|

  verb.command :note do |noun|

    noun.desc "phrase must be in note's title"
    noun.flag :title

    noun.action do |global_options,options,args|

      filter = Evernote::EDAM::NoteStore::NoteFilter.new
      filter.order = Evernote::EDAM::Type::NoteSortOrder::UPDATED
      words = []
      if not args.empty?
        words += args
      end
      if options[:title]
        words << " intitle:\"#{options[:title]}\""
      end
      if not words.empty?
        filter.words = words.join(' ') # TODO join phrases using quotes and quote escaping
      end
      persister = EvernoteCLI::Persister.new
      client = EvernoteCLI::Auth.new(persister).client
      notes = client.note_store.findNotes(filter,0,20).notes

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

    end
  end
end

