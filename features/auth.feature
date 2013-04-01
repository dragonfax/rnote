@announce
Feature: Authentication
  Verify that you can login and logout of Evernote.
  
  Background:
    # login once to sae the consumer secret and key
    Given I run `rnote login --user=<username> --password=<password> --key=<consumer-key> --secret=<consumer-secret> --sandbox` with credentials
  
  Scenario: Login, with options
    Given I am logged out
    # note this is a bad cucumber practice, see features/README.md
    When I run `rnote login --user=<username> --password=<password> --sandbox` with credentials
    Then I should be logged in as "<username>"

  Scenario: Login interactively
    Given I am logged out
    When I run `rnote login --sandbox` interactively
    And I type "<username>"
    And I type the password
    Then I should be logged in as "<username>"

  Scenario: Who
    Given I am logged in as <username>
    When I run `rnote who`
    Then the output should contain the username

  Scenario: Double Login
    Given I am logged in as <username>
    When I run `rnote login --user=<username2> --password=<password2> --sandbox` with credentials
    Then I should be logged in as "<username2>"

  Scenario: Logout
    Given I am logged in as <username>
    When I run `rnote logout`
    Then I should not be logged in

  Scenario: Double Logout
    Given I am logged out
    When I run `rnote logout`
    Then I should not be logged in

  Scenario: Login with developer token
    Given I am logged out
    When I run `rnote login --dev-token <dev-token> --sandbox` with credentials
    Then the exit status should be 0

  ## Additional credential options

  # TODO Scenario: login with developer token
  # TODO Scenario: provide consumer key and secret
