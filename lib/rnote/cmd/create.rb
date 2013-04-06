
require 'gli'

require 'rnote/noun/note/edit'
require 'rnote/noun/tag/find'

include GLI::App


d 'create a new note'
long_desc <<EOF
Create a new note and, optionally, launch an editor to provide its content

Unlike most commands, the command line arguments aren't used in a search.
Instead any command line arguments provided are used for the title of the new note.
EOF
command :create do |verb|
  
  d 'create a new tag'
  verb.command :tag do |noun|
    
    # TODO check that the tag doesn't already exist
    
    noun.action do |global_options, options, args|
      
      if args.length < 1
        raise "You must provide the tag name."
      end
      if args.length > 1
        raise "You can only provide one tag name to create."
      end
      
      tag_name = args[0]
      
      # verify tag doesn't exist
      if Rnote::Tag.get_tag_by_name(tag_name)
        raise "tag #{tag_name} already exists"
      end

      # create the tag
      tag = Evernote::EDAM::Type::Tag.new()
      tag.name = tag_name
      $app.auth.client.note_store.createTag(tag)
      puts "tag created"
      
    end
    
  end

  d 'create a new note'
  verb.command :note do |noun|

    Rnote::Edit.include_set_options(noun)
    Rnote::Edit.include_editor_options(noun)

    noun.action do |global_options,options,args|

      if args.length > 0
        if options[:'set-title']
          raise "You can't use both --set-title and command line arguments at the same time to set the title of the new note."
        end
        options[:'set-title'] = args.join(' ')
      end

      edit = Rnote::Edit.new($app.auth)
      edit.options(options.merge(global_options))
      edit.edit_action


    end
  end
  
  verb.default_command :note
end
