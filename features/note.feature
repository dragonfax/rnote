Feature:
  Create and manipulate notes in Evernote.

  Background:
    Given I am logged in as dragonfax
    And I have 0 notes
    
  Scenario: Show note
    Given that I have a note named "foo" with content "bar"
    When I run `rnote show note --title "foo"`
    Then the output should contain "bar"
    
  Scenario: Show note, from multiple notes
    Given that I have 2 notes named "foo"
    When I run `rnote show note --title "foo"` interactively
    And I type "1"
    Then the output should contain "foo"
    
  Scenario: Show note, after a "find"
    Given that I have 2 notes named "foo"
    When I run `rnote find note --title "foo"`
    And I run `rnote show note 1`
    Then the output should contain "foo"
      
  @announce
  Scenario: Create note without editor
    Given that I have 0 notes named "test note"
    When I run `rnote create note --set-title 'test note' --no-editor`
    Then the note named "test note" should be empty 

  Scenario: Create note with editor
    Given that I have 0 notes named "test note"
    When I run `rnote create note --set-title 'test note'` with editor
    And I type "test content"
    And I exit the editor
    Then the note named "test note" should contain "test content"

  Scenario: Edit note with editor
    Given that I have 1 note named "test note"
    When I run `rnote edit note --title 'test note'` with editor
    And I type "test content"
    And I exit the editor
    Then the note named "test note" should contain "test content"
    
    
  Scenario: Delete note
    Given that I have 1 note named "test note"
    When I run `rnote remove note --title "test note"` interactively
    And I type "Yes"
    Then I should have 0 notes named "test note"
    
  Scenario: Delete a note, from multiple notes
    Given that I have 2 notes named "test note"
    When I run `rnote remove note --title "test note"` interactively
    And I type "1"
    And I type "Yes"
    Then I should have 1 note named "test note"
    
   Scenario: Delete a note after a "find"
     Given that I have 2 note named "test note"
     When I run `rnote find note --title "test note"` interactively
     When I run `rnote remove note 1`
     And I type "Yes"
     Then I should have 1 note named "test note"
    
    
    
