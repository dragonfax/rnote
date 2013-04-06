
require 'highline/import'
require 'rnote/noun/note/find'

include GLI::App



d 'remove a note'
long_desc "Remove a note, but don't expunge it. The note stays in the users Trash"
command :remove do |verb|

  verb.desc 'remove a note'
  verb.command :note do |noun|
    
    Rnote::Find.include_search_options(noun)
  
    noun.action do |global_options,options,args|
      
      find = Rnote::Find.new($app.auth,$app.persister)
      note = find.find_note(options.merge(global_options),args) 
      
      puts note.summarize
      
      answer = agree("Delete this note. Are you sure?  ")
      if answer
        $app.client.note_store.deleteNote(note.guid)
      else
        puts "Alright, delete cancelled."
      end
      
    end
    
  end
  
  verb.default_command :note
end


