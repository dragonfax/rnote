
require 'highline/import'
require 'evernote-thrift'
require 'rnote/converter'

module Rnote

  class Find
    
    # Warning
    # Don't take the Notes resulting from these searches and try to update them in Evernote
    # they may not be fully populate, missing tags, or content.
    # instead just use this list to display the note lists, or to get the guid and pull the whole note again.

    MAX_RESULTS_PER_PAGE = 10

    def initialize(auth,persister)
      @auth = auth # auth instead of client so I can postpone connecting.
      @persister = persister
    end

    # runs a search
    # returns the results
    def search(options,args)

      # process arguments into an evernote search query
      filter = Evernote::EDAM::NoteStore::NoteFilter.new
      filter.order = Evernote::EDAM::Type::NoteSortOrder::UPDATED
      if options[:title]
        args << "intitle:'#{options[:title]}'"
      end
      filter.words = args.join(' ')

      page = 0
      notes = @auth.client.note_store.findNotes(filter,page * MAX_RESULTS_PER_PAGE,MAX_RESULTS_PER_PAGE).notes
      
      # we fully pouplate each note at search time
      # poor choice for performance, though
      notes.each do |note|
        note.content = @auth.client.note_store.getNoteContent(note.guid)
        note.tagNames = @auth.client.note_store.getNoteTagNames(note.guid)
      end

      notes
    end

    # runs the search
    # displays it
    # saves it.
    # returns nothing
    def find_cmd(options,args)

      results = search(options,args)

      if results.empty?
        @persister.save_last_search([])
        puts "no notes found"
      else
        @persister.save_last_search(results)
        display_results(results)
      end
    end


    def display_results(notes)
      inc = 0
      notes.each do |note|
        puts "#{inc}: #{note.title}\n#{note.summarize}\n"
        inc += 1
      end
    end

    def Find.include_search_options(noun)
      noun.desc "phrase to find in title of note"
      noun.flag :title
    end

    def Find.has_search_options(options)
      options[:title].nil?
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
        results = search(options,args)
      end

      if results.length == 0
        raise "no matching note found."
      elsif results.length == 1
        return results[0]
      else
        if options[:interactive]
          display_results(results)
          answer = ask 'Which note? ', Integer do |q|
            q.in = 1..results.length
          end
          results[answer - 1]
        else
          raise 'too many results. or try --interactive to select'
        end
      end

    end
    
  end


end