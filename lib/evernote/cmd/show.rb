
include GLI::App

desc 'output notes to the console'
command :show do |verb|

  verb.desc 'find and output notes to the console'
  verb.command :note do |noun|

    noun.flag :title

    noun.action do |global_options,options,args|

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
        exit
      elsif notes.size == 1
        puts client.note_store.getNote(notes.first.guid,true,false,false,false).content
      else
        raise "unimplemented"
      end


    end

  end
end



