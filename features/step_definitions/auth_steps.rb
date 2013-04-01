

## Given

Given /^I am logged in as <username>$/ do
  if `rnote who`.chomp != SANDBOX_USERNAME1
    step 'I run `rnote login --user=<username> --password=<password> --consumer-key=<consumer-key> --consumer-secret=<consumer-secret> --sandbox` with credentials'
    step 'I should be logged in as "<username>"'
  end
end

Given /^I am logged out$/ do
  step 'I run `rnote logout`'
  step "I should not be logged in"
end

## When

When /^I run `(.*?)` with credentials$/ do |arg1|
  arg1.sub!('<username>', SANDBOX_USERNAME1)
  arg1.sub!('<username2>', SANDBOX_USERNAME2)
  arg1.sub!('<password>', SANDBOX_PASSWORD1)
  arg1.sub!('<password2>', SANDBOX_PASSWORD2)
  arg1.sub!('<consumer-key>', SANDBOX_CONSUMER_KEY)
  arg1.sub!('<consumer-secret>', SANDBOX_CONSUMER_SECRET)
  arg1.sub!('<dev-token>', SANDBOX_DEVELOPER_TOKEN)
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

Then /^I should be logged in as "<(.+)>"$/ do |which_user|
  username = which_user == 'username' ? SANDBOX_USERNAME1 : SANDBOX_USERNAME2
  step 'I run `rnote who`'
  step "the output should contain \"#{username}\""
end

Then /^I should not be logged in as "<(.+)>"$/ do |which_user|
  username = which_user == 'username' ? SANDBOX_USERNAME1 : SANDBOX_USERNAME2
  step 'I run `rnote who`'
  step "the output should not contain \"#{username}\""
end

Then /^the output should contain the username$/ do
  step "the output should contain \"#{SANDBOX_USERNAME1}\""
end

