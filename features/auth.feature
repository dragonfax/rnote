Feature: Authentication
  Verify that you can login and logout of Evernote.

  Scenario: Login, with options
    Given I am logged out
    # note this is a bad cucumber practice, see features/README.md
    When I run "evernote login --user dragonfax --password #{password}" with password
    Then I should be logged in as "dragonfax"

  Scenario: Login, interactively
    Given I am logged out
    When I run "evernote login" interactively
    And I type "dragonfax"
    And I type the password
    Then I should be logged in as "dragonfax"

  Scenario: Who
    Given I am logged in as dragonfax
    When I run "evernote who"
    Then the output should contain "dragonfax"

  Scenario: Double Login
    Given I am logged in as dragonfax
    When I run "evernote login --user user2 --password #{password}" with password
    Then I should be logged in as "user2"
    And I should not be logged in as "dragonfax"

  Scenario: Logout
    Given I am logged in as dragonfax
    When I run "evernote logout"
    Then I should not be logged in

  Scenario: Double Logout
    Given I am logged out
    When I run "evernote logout"
    Then I should not be logged in

