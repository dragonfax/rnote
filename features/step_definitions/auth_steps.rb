

## Given

Given /^I am logged in as dragonfax_test1$/ do
  if `rnote who`.chomp != 'dragonfax_test1'
    step 'I run `rnote login --user=dragonfax_test1 --password=<password> --consumer-key=<consumer-key> --consumer-secret=<consumer-secret> --sandbox` with credentials'
    step 'I should be logged in as "dragonfax_test1"'
  end
end

Given /^I am logged out$/ do
  step 'I run `rnote logout`'
  step "I should not be logged in"
end

## When

When /^I run `(.*?)` with credentials$/ do |arg1|
  arg1.sub!('<username>', SANDBOX_USERNAME1)
  arg1.sub!('<password>', SANDBOX_PASSWORD1)
  arg1.sub!('<password2>', SANDBOX_PASSWORD2)
  arg1.sub!('<consumer-key>', SANDBOX_CONSUMER_KEY)
  arg1.sub!('<consumer-secret>', SANDBOX_CONSUMER_SECRET)
  step "I run `#{arg1}`"
end

When /^I type the password$/ do
  step "I type \"#{SANDBOX_PASSWORD1}\""
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

