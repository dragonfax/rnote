
require 'gli'

include GLI::App

d 'list items in evernote'
long_desc 'list items such as notes, tags, notebooks, without displaying their content.'

command :list do |verb|
  
  d 'list all tags in the account'
  verb.command :tags do |noun|
    
    noun.action do |global_options, options, args|
      $app.auth.client.note_store.listTags.each { |tag| puts tag.name }
    end
    
  end
end