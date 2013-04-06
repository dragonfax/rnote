@announce
Feature:
  Create and manipulate Evernote tags.

  Background:
    Given I am logged in as <username>
    
  Scenario: List tags
    Given that I have a tag named "blah1"
    And that I have a tag named "blah2"
    When I run `rnote list tags`
    Then the exit status should be 0
    And the output should contain "blah1"
    And the output should contain "blah2"
    
  # API can't delete tags, so we can't have automated tests creating/deleting tags
  #
  #Scenario: Delete tag
  #  Given that I have a tag names "blah1"
  #  When I run `rnote delete tag blah1`
  #  Then the exit status should be 0
  #  And I should not have a tag named "blah1"
  #
  #Scenario: Create tag
  #  Given that I don't have a tag named "blah1"
  #  When I run `rnote create tag blah1`
  #  Then the exit status should be 0
  #  And I should have a tag named "blah1"
  #  
  #Scenario: Rename tag
  #  Given that I have a tag named "blah1"
  #  And that I don't have a tag named "blah2"
  #  When I run `rnote rename blah1 blah2`
  #  Then the exit status should be 0
  #  And I should not have a tag named "blah1"
  #  And I should have a tag named "blah2"
