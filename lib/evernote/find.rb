
require 'highline'
require 'evernote-thrift'
require 'evernote/converter'

module EvernoteCLI

  class Find

    MAX_RESULTS_PER_PAGE = 10

    def initialize(auth,persister)
      @auth = auth # auth instead of client so I can postpone connecting.
      @persister = persister
      @converter = Converter.new
    end

    # runs a search
    # returns the results
    def find_notes(options,args)

      # process arguments into an evernote search query
      filter = Evernote::EDAM::NoteStore::NoteFilter.new
      filter.order = Evernote::EDAM::Type::NoteSortOrder::UPDATED
      filter.words = args.join(' ')

      page = 0
      notes = @auth.client.note_store.findNotes(filter,page * MAX_RESULTS_PER_PAGE,MAX_RESULTS_PER_PAGE).notes
      response_to_results(notes)

    end

    # runs the search
    # displays it
    # saves it.
    # returns nothing
    def find_cmd(options,args)

      results = find_notes(options,args)

      if results.empty?
        @persister.save_last_search([])
        puts "no notes found"
      else
        @persister.save_last_search(results)
        display_results(results)
      end
    end

    def response_to_results(notes)
      notes.map do |note|
        tags = @auth.client.note_store.getNoteTagNames(note.guid)
        brief = @converter.enml_to_raw_markdown(@auth.client.note_store.getNoteContent(note.guid))[0..30]
        { title: note.title, guid: note.guid, tags: tags, brief: brief }
      end
    end

    def display_results(results)
      inc = 0
      results.each do |result|
        puts "#{inc}: #{result[:title]} - #{result[:tags].join(',')}\n#{result[:brief]}\n"
        inc += 1
      end
    end

    def Find.include_search_options(nount)
      # --title and the like
    end

    def Find.has_search_options(options)
      # options[:title].nil?
      false
    end

    # get the note to edit. whether from options or last search result or interactively
    # run a searching using the options and/or arguments
    # use last search if it makes sense to do so.
    # returns a note
    def find_note(options,args)

      results = nil
      if args.length == 1 and not has_search_options(options) and args[0].matchs /^\d{1,3}$/
        # no search options, one argument, and its a small number
        # use the cached search results
        results = @persister.get_last_results
      else
        results = find_notes(options,args)
      end

      if results.length == 0
        raise "no matching note found."
      elsif results.length == 1
        return result_to_note(results[0])
      else
        if options[:interactive]
          display results
          asnwer = ask 'Which note? ', Integer do |q|
            q.in = 1..results.length
          end
          result_to_note(results[answer - 1])
        else
          raise 'too many results. or try --interactive to select'
        end
      end

    end

  end

  def result_to_note(result)
    @auth.client.note_store.getNote(result[:guid])
  end

end