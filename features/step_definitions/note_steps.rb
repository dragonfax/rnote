
require 'evernote-thrift'
require 'minitest/autorun'

Given /^that I have (\d+) notes? named "(.*?)"$/ do |arg1, arg2|
  filter = Evernote::EDAM::NoteStore::NoteFilter.new
  filter.words = "intitle:\"#{arg2}\""
  notes = client.note_store.findNotes(filter,0,99).notes
  
  # delete notes if necessary
  while notes.length > arg1.to_i
    client.note_store.deleteNote(notes.pop.guid)
  end
  
  # create notes if necessary
  note = Evernote::EDAM::Type::Note.new
  note.title = arg2
  note.content = Rnote.markdown_to_enml('')
  while notes.length < arg1.to_i
    new_note = client.note_store.createNote(note)
    notes << new_note
  end
end
 
Given /^that I have a note named "(.*?)" with content "(.*?)"$/ do |arg1, arg2|
  filter = Evernote::EDAM::NoteStore::NoteFilter.new
  filter.words = "intitle:\"#{arg1}\""
  notes = client.note_store.findNotes(filter,0,99).notes
  
  note = nil
  if notes.length > 1
    while notes.length > 1
      client.note_store.deleteNote(notes.pop.guid)
    end
    note = notes.first
  elsif notes.length == 0
    note = Evernote::EDAM::Type::Note.new
    note.title = arg1
    note.content = Rnote.markdown_to_enml('')
    note = client.note_store.createNote(note)
  else
    note = notes.first
  end
  
  note.content = Rnote.markdown_to_enml(arg2)
  client.note_store.updateNote(note)
  
end

Given /^I have (\d+) notes?$/ do |arg1|
  filter = Evernote::EDAM::NoteStore::NoteFilter.new
  notes = client.note_store.findNotes(filter,0,99).notes
  while notes.length > arg1.to_i
    begin
    client.note_store.deleteNote(notes.pop.guid)
    rescue Evernote::EDAM::Error::EDAMUserException => e
      puts e.errorCode
      puts e.parameter
      raise e
    end
  end
end


When /^I run `(.*?)` with editor$/ do |arg1|

  previous_value = ENV['EDITOR']
  ENV['EDITOR'] = 'tee'
  begin

    step "I run `#{arg1}` interactively"

  ensure
    if previous_value
      ENV['EDITOR'] = previous_value
    end
  end

end

When /^I exit the editor$/ do
  step 'I type ""'
end


Then /^I should have (\d+) notes? named "(.*?)"$/ do |arg1,arg2|
  filter = Evernote::EDAM::NoteStore::NoteFilter.new
  filter.words = "intitle:\""#{arg2}\"
  notes = client.note_store.findNotes(filter,0,99).notes
  assert_equal arg1.to_i, notes.length
end
 
Then /^the note named "(.*?)" should be empty$/ do |arg1|
  filter = Evernote::EDAM::NoteStore::NoteFilter.new
  filter.words = "intitle:\"#{arg1}\""
  notes = client.note_store.findNotes(filter,0,99).notes
  assert_equal 1,notes.length
  note = notes.first
  content = client.note_store.getNoteContent(note.guid)
  assert_equal '',enml_to_markdown(content)
end

Then /^the note named "(.*?)" should contain "(.*?)"$/ do |arg1, arg2|
  step "I run `rnote show note --title \"#{arg1}\"`"
  step "the output should contain \"#{arg2}\""
end
