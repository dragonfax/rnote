
require 'evernote-thrift'
require 'minitest/autorun'

def notes_by_title(title)
  filter = Evernote::EDAM::NoteStore::NoteFilter.new
  filter.words = "intitle:\"#{title}\""
  note_list = client.note_store.findNotes(filter,0,99)
  notes = note_list.notes
  notes.each do |note|
    note.content = client.note_store.getNoteContent(note.guid)
  end
  
  notes
end

Transform /^(-?\d+) notes?$/ do |number|
  number.to_i
end


def create_note(title,content='')
  note = Evernote::EDAM::Type::Note.new
  note.title = title
  note.txt_content = content
  client.note_store.createNote(note)
end


Given /^I have (\d+ notes?)$/ do |count|
  step "that I have #{count} notes named \"whatever\""
end

Given /^that I have (\d+ notes?) named "([^"]+?)"$/ do |count, title|
  step "that I have #{count} notes named \"#{title}\" with content \"whatever\""

end

Given /^that I have (\d+ notes?) named "([^"]+?)" with content "([^"]*?)"$/ do |count, title, content|
  notes = notes_by_title(title)
  
  # delete notes if necessary
  while notes.length > count
    client.note_store.deleteNote(notes.pop.guid)
  end
  
  # set content on any kept notes. if necessary
  notes.each do |note|
    if note.txt_content != content
      note.txt_content = content
      client.note_store.updateNote(note)
    end
  end
  
  # create notes if necessary
  while notes.length < count
    notes << create_note(title,content)
  end

  assert_equal count, notes_by_title(title).length
end
 
When /^I run `(.*?)` with vim$/ do |command|

  previous_value = ENV['EDITOR']
  ENV['EDITOR'] = 'vim'
  begin

    step "I run `#{command}` interactively"

  ensure
    if previous_value
      ENV['EDITOR'] = previous_value
    end
  end

end

When /^I run `(.*?)` with editor$/ do |command|

  previous_value = ENV['EDITOR']
  ENV['EDITOR'] = 'tee'
  begin

    step "I run `#{command}` interactively"

  ensure
    if previous_value
      ENV['EDITOR'] = previous_value
    end
  end

end

When /^I exit the editor$/ do
  step 'I type ""'
end

When /^I wait (\d+) seconds$/ do |timeout|
  sleep(timeout.to_i)
end


Then /^I should have (\d+ notes?) named "(.*?)"$/ do |count,title|
  assert_equal count, notes_by_title(title).length
end
 
Then /^the note named "(.*?)" should be empty$/ do |title|
  notes = notes_by_title(title)
  assert_equal 1,notes.length
  note = notes.first
  assert_equal '',note.txt_content
end

Then /^the note named "(.*?)" should contain "(.*?)"$/ do |title, content|
  # can't use aruba here, as i want this to be callable while an interactive command is being run.
  notes = notes_by_title(title)
  assert notes.length > 0
  matching_notes = notes.select { |note| note.content.include?(content) }
  assert matching_notes.length > 0, 'at least one note with matching content'
end

Then /^the note named "(.*?)" should eventually contain "(.*?)"$/ do |title, content|
  # can't use substeps here, as i want this to be callable while an interactive command is being run.
  time_started = Time.new
  while true
    begin
      step %{the note named "#{title} should contain "#{content}"}
    rescue MiniTest::Assertion => e
      time_now = Time.new
      seconds = time_now - time_started
      if seconds > @aruba_timeout_seconds
        puts "timeout exceeded waiting for note with content"
        raise e
      end
    else
      break
    end
    
    sleep 1
  end
end
