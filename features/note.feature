Feature:
  Create and manipulate notes in Evernote.

  Background:
    Given I am logged in as dragonfax

  @announce
  Scenario: Create and edit note with editor
    Given that I don't have a note named "test note"
    When I run `evernote create note --title 'test note'` with editor
    And I type "test content"
    And I exit the editor
    Then the note named "test note" should contain "test content"

