
require 'evernote-thrift' # TODO shoulnd't have to include the library

Given /^that I don't have a note named "(.*?)"$/ do |arg1|

  # TODO lacking a "delete note if exists" command, I'll code my own for now.
  # Note: this breaks the feature coding philosophy for this library. features/README.md
  #       so eventually this should be replaced with a properl "evernote" command and step
  filter = Evernote::EDAM::NoteStore::NoteFilter.new
  filter.words = "intitle:\"#{arg1}\""
  notes = client.note_store.findNotes(filter,0,1).notes
  notes.each do |note|
    client.note_store.deleteNote(note.guid)
  end

  # verify
  step "I run `rnote find note --title '#{arg1}'`"
  step "the output should contain \"no notes found\""

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

Then /^the note named "(.*?)" should contain "(.*?)"$/ do |arg1, arg2|
  step "I run `rnote show note --title \"#{arg1}\"`"
  step "the output should contain \"#{arg2}\""
end