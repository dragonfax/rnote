@announce
Feature:
  Create and manipulate notes in Evernote.

  Background:
    Given I am logged in as <username>
    And I have 0 notes
    
  Scenario: Show note
    Given that I have 1 note named "foo" with content "bar"
    When I run `rnote show note --title "foo"`
    Then the output should contain "bar"
    
  Scenario: Show note, from multiple notes
    Given that I have 2 notes named "foo"
    When I run `rnote show note --title "foo"` interactively
    And I type "1"
    Then the output should contain "foo"
    
  Scenario: Show note after a "find"
    Given that I have 2 notes named "foo"
    When I run `rnote find note --title "foo"`
    Then the exit status should be 0
    And I run `rnote show note 1`
    Then the exit status should be 0
    Then the output should contain "foo"
      
  Scenario: Create note without editor
    Given that I have 0 notes named "test note"
    When I run `rnote create note --set-title 'test note' --no-editor`
    Then the note named "test note" should be empty 

  Scenario: Create note with editor
    Given that I have 0 notes named "test note"
    When I run `rnote create note --set-title 'test note' --no-watch` with vim
    And I type "Gotest content"
    # quit editor
    And I type ":wq"
    Then the exit status should be 0
    And the note named "test note" should contain "test content"

  Scenario: Edit note with editor
    Given that I have 1 note named "test note"
    When I run `rnote edit note --title 'test note' --no-watch` with vim
    And I type "Gotest content"
    And I type ":wq"
    Then the exit status should be 0
    And the note named "test note" should contain "test content"
    
  Scenario: Create note with VIM, watching for changes every second
    When I run `rnote create note --set-title 'test note'` with vim
    # end of file
    And I type "G"
    # add line below cursor
    And I type "otest content1"
    # save the changes
    And I type ":w"
    Then the note named "test note" should contain "test content1"
    # next phase of the test, odd for cucumber tests, I know.
    When I type "otest content2"
    And I type ":w"
    Then the note named "test note" should contain "test content2"
    When I type ":wq"
    Then the exit status should be 0
     
  Scenario: Delete note
    Given that I have 1 note named "test note"
    When I run `rnote remove note --title "test note"` interactively
    And I wait for output to contain "Are you sure"
    And I type "Yes"
    Then the exit status should be 0 
    And I should have 0 notes named "test note"
    
  Scenario: Delete a note from multiple notes
    Given that I have 2 notes named "test note"
    When I run `rnote remove note --title "test note"` interactively
    And I wait for output to contain "Which note"
    And I type "1"
    And I wait for output to contain "Are you sure"
    And I type "Yes"
    Then the exit status should be 0 
    Then I should have 1 note named "test note"
    
  Scenario: Delete a note after a "find"
    Given that I have 2 notes named "test note"
    When I run `rnote find note --title "test note"` interactively
    Then the output should contain "test note"
    And the exit status should be 0
    When I run `rnote remove note 1` interactively
    Then I wait for output to contain "Are you sure"
    And I type "Yes"
    Then the exit status should be 0 
    Then I should have 1 note named "test note"
    
    
    
