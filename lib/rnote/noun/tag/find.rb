
module Rnote
  
  module Tag
    
    def self.get_tag_by_name(tag_name)
      # TODO Do I really have to search through all tags manually?
      tags = $app.auth.client.note_store.listTags.select { |tag| tag.name.downcase == tag_name.downcase }
      if tags.empty?
        nil
      else
        tags.first
      end
    end
  end
  
end