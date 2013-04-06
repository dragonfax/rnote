
require 'gli'

require 'rnote/noun/tag/find'

include GLI::App

d 'rename an item in evernote'
long_desc <<EOF
Rename a tag, notebook or a note without change the content or other details of the note

Note that for notes this can also be acheived simply by editing the note. Or running:

$ rnote edit note --title "old note title" --set-title "new note title" --no-editor
EOF

command :rename do |verb|
  
  verb.desc 'rename a tag'
  verb.command :tag do |noun|
    
    noun.action do |global_options,options,args|

      old_tag_name = args[0]
      new_tag_name = nil
      if args.length < 2
        raise "not enough arguments, must specify both old and new tag name"
      elsif args.length == 2
        new_tag_name = args[1]
      elsif args.length == 3 and args[1] == 'to'
        new_tag_name = args[2]
      else
        raise "too many arguments"
      end
      
      tag = Rnote::Tag.get_tag_by_name(old_tag_name)
      
      tag.name = new_tag_name
      $app.auth.client.note_store.updateTag(tag)
      
    end
    
  end
  
end
