
require 'evernote/version.rb'

# verbs
Dir[File.absolute_path(File.dirname(__FILE__)) + '/evernote/cmd/*.rb'].each do |file|
 require file
end

# internal modules
require 'evernote/auth'
