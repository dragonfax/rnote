
require_relative './auth_steps'

Given /^that I don't have a note named "(.*?)"$/ do |arg1|

  I need more here to delete this note if it exists.

  # this is just verification here.
  step "I run \"evernote find note --title '#{arg1}'\""
  step "the output should contain \"no notes found\""

end

When /^I run "(.*?)" with editor$/ do |arg1|

  ENV['EDITOR'] = 'cat'
  step "I run \"#{arg1}\" interactively"

end

When /^I exit the editor$/ do
  step 'I type ""'
end

Then /^the note named "(.*?)" should contain "(.*?)"$/ do |arg1, arg2|
  step "I run \"evernote show --title '#{arg1}'\""
  step "the output should contain \"#{arg2}\""
end