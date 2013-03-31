
require 'rnote/find'
require 'highline/import'

include GLI::App



desc 'remove an item from evernote'
arg_name 'Describe arguments to remove here'
command :remove do |verb| 
  
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


