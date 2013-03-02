
include GLI::App

MAX_RESULTS_PER_PAGE = 10

desc 'search for notes/tags/notebooks'
arg_name :noun
command :find do |verb|

  verb.command :note do |noun|

    noun.desc "don't hit the api, just show the last search results"
    noun.switch :cached

    noun.action do |global_options,options,args|

      persister = EvernoteCLI::Persister.new

      if options[:cached]

        raise "Can't take any other search arguments with --cached" if args.length > 0

        inc = 0
        persister.get_last_search.each do |result|
          puts "#{inc}: #{result[:title]} - #{result[:tags].join(',')}\n#{result[:brief]}\n"
          inc += 1
        end
      else

        # process arguments into an evernote search query
        filter = Evernote::EDAM::NoteStore::NoteFilter.new
        filter.order = Evernote::EDAM::Type::NoteSortOrder::UPDATED
        filter.words = args.join(' ')

        converter = EvernoteCLI::Converter.new

        client = EvernoteCLI::Auth.new(persister).client
        page = 0
        notes = client.note_store.findNotes(filter,page * MAX_RESULTS_PER_PAGE,MAX_RESULTS_PER_PAGE).notes

        #TODO use note metadata instead of notes themselves

        if notes.empty?
          puts "no notes found"
          persister.save_last_search([])
        else
          inc = 1
          last_search = []
          notes.each do |note|
            tags = client.note_store.getNoteTagNames(note.guid)
            brief = converter.enml_to_raw_markdown(client.note_store.getNoteContent(note.guid))[0..30]
            puts "#{inc}: #{note.title} - #{tags.join(',')}\n#{brief}\n"
            last_search << { title: note.title, guid: note.guid, tags: tags, brief: brief }
            inc += 1
          end
          persister.save_last_search(last_search)
        end
      end

    end
  end
end

