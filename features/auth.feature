Feature: Authentication
  Verify that you can login and logout of Evernote.

  Scenario: Login
    Given that I am logged out
    When I run "evernote login --user jstillwell --password password"
    Then the exit status should be 0

  # TODO logs out first if already logged in
  # TODO should ask for user and/or pass if not given

  Scenario: Logout
    When I run "evernote logout"
    Then the exit status should be 0

  # TODO harmless when already logged out
