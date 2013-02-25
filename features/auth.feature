Feature: Authentication
  Verify that you can login and logout of Evernote.

  Scenario: Login, with options
    Given I am logged out
    # note this is a bad cucumber practice, see features/README.md
    When I run "evernote login --user #{username} --password #{password}" with variables
      |username|
      |password|
    Then I am logged in

  Scenario: Login, interactively
    Given I am logged out
    When I run "evernote login"
    And I type the username
    And I type the password
    Then I am logged in

  Scenario: Who
    Given I am logged in
    When I run "evernote who"
    Then the output should contain the username

  Scenario: Double Login
    Given I am logged in as user1
    When I login as user2
    Then I am logged in as user2
    And I am not logged in as user1

  Scenario: Logout
    Given I am logged in
    When I run "evernote logout"
    Then I am not logged in

  Scenario: Double Logout
    Given I am logged out
    When I run "evernote logout"
    Then I am not logged in

