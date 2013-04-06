
def find_tag(name)
  tags = client.note_store.listTags.select { |tag| tag.name.downcase == name.downcase }
  if tags.empty?
    nil
  else
    tags.first
  end
end

Given(/^that I have a tag named "(.*?)"$/) do |tag_name|
  unless find_tag(tag_name)
    tag = Evernote::EDAM::Type::Tag.new
    tag.name = tag_name
    client.note_store.createTag(tag)
  end
  assert find_tag(tag_name)
end

Then(/^I should have a tag named "(.*?)"$/) do |tag_name|
  assert find_tag(tag_name)
end

Then(/^I should not have a tag named "(.*?)"$/) do |tag_name|
  refute find_tag(tag_name)
end

