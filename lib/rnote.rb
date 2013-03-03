
require 'rnote/version'
require 'rnote/converter'
require 'rnote/persister'
require 'rnote/auth'

# verbs
Dir[File.absolute_path(File.dirname(__FILE__)) + '/rnote/cmd/*.rb'].each do |file|
 require file
end


module Rnote

  class App

    attr_reader :persister,:auth

    def initialize
      @persister = Persister.new
      @auth = Auth.new(@persister)
    end

    def client
      auth.client
    end

  end

end


class Evernote::EDAM::Type::Note
  
  # we use this to track if this note came from our search cache
  # it means the note may not be fully pouplated.
  
  def summarize
    "#{Rnote.enml_to_markdown(self.content)[0..30]}\n"
  end
  
  # The yaml stream is what we give to the user to edit in their editor
  # 
  # Its just a string, but its composed of 2 parts. the note attributes and the note content.
  #
  # 1. a small yaml document with the note attributes as a hash.
  # 2. followed by the note content as markdown
  def self.from_yaml_stream(yaml_stream)

    m = yaml_stream.match /^(---.+?---\n)(.*)$/m
    raise "failed to parse yaml stream\n#{yaml_stream}" unless m

    attributes_yaml = m[1]
    markdown = m[2]

    enml = Rnote.markdown_to_enml(markdown)
    attributes_hash = YAML.load(attributes_yaml)

    note = self.new
    note.title = attributes_hash['title']
    note.content = enml
    
    note
  end
  
  def to_yaml_stream()
    YAML.dump({ 'title' => title }) + "\n---\n" + Rnote.enml_to_markdown(content)
  end

end

