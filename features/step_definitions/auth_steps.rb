

## Given

Given /^I am logged in as dragonfax$/ do
  Given 'I am logged out'
  When 'I run "evernote login --user user2 --password #{password}" with password'
  Then 'I should be logged in as "dragonfax"'
end

Given /^I am logged out$/ do
  When 'I run "evernote logout"'
  Then "I should not be logged in"
end

## When

When /^I run "(.*?)" with password$/ do |arg1|
  arg1.sub!('#{password}', @password)
  When "I run \"arg1\""
end

When /^I type the password$/ do
  When "I type \"#{@password}\""
end

## Then

Then /^I should not be logged in$/ do
  When 'I run "evernote who"'
  Then 'the output should contain "You are not logged in as any user."'
end

Then /^I should be logged in as "(.+)"$/ do |arg1|
  When 'I run "evernote who"'
  Then "the output should contain \"#{arg1}\""
end

Then /^I should not be logged in as "(.+)"$/ do |arg1|
  When 'I run "evernote who"'
  Then "the output should not contain \"#{arg1}\""
end

