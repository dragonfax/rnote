
require 'highline/import'
require 'rnote/noun/note/find'
require 'rnote/noun/tag/find'

include GLI::App



d 'remove a note'
long_desc "Remove a note, but don't expunge it. The note stays in the users Trash"
command :remove do |verb|
  
  verb.desc 'remove a tag (expunge, but not truly delete)'
  verb.command :tag do |noun|
    
    noun.action do |global_options, options, args|
      
      if $app.auth.login_type != :developer_token
        raise "Only a developer token has the expunge permisisons necessary to delete a tag. A user/password cannot delete tags."
      end
      
      tag_name = args[0]
      tag = Rnote::Tag.get_tag_by_name(tag_name)
      $app.auth.client.note_store.expungeTag(tag.guid)
      
    end
    
  end

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


