

## Given

Given /^I am logged in as dragonfax_test1$/ do
  step 'I run `rnote login --user=dragonfax_test1 --password=<password>` with password'
  step 'I should be logged in as "dragonfax_test1"'
end

Given /^I am logged out$/ do
  step 'I run `rnote logout`'
  step "I should not be logged in"
end

## When

When /^I run `(.*?)` with password$/ do |arg1|
  arg1.sub!('<password>', password)
  step "I run `#{arg1}`"
end

When /^I type the password$/ do
  step "I type \"#{password}\""
end

## Then

Then /^I should not be logged in$/ do
  step 'I run `rnote who`'
  step 'the output should contain "You are not logged in as any user."'
end

Then /^I should be logged in as "(.+)"$/ do |arg1|
  step 'I run `rnote who`'
  step "the output should contain \"#{arg1}\""
end

Then /^I should not be logged in as "(.+)"$/ do |arg1|
  step 'I run `rnote who`'
  step "the output should not contain \"#{arg1}\""
end

