Feature: Notebooks
  That I can manipulate notebooks.

  Background:
    Given that I am logged in

  Scenario: Create Notebook
    When I run "evernote create notebook 'test1'"
    Then the exit status should be 0

  # TODO can also use --notebook option to name the notebook

  Scenario: Remove Notebook, with unambiguous name
    Given I have a notebook named 'test1'
    When I run "evernote remove notebook 'test1'"
    And I should have 0 notebooks

  # TODO cn use --notebook

  Scenario: Remove Notebook, with ambiguous name
    Given I have a notebook named "test11"
    And I have a notebook named "test12"
    When I run "evernote remove notebook 'test1'" interactively
    And I type "1"
    And I should have 1 notebook
    And I should have a notebook named "test12"


  Scenario: Rename Notebook, with unambiguous name
    Given that I have a notebook named "test1"
    When I run "evernote rename notebook 'test1' 'test2'"
    Then I do not have a notebook named "test1"
    And I have a notebook named "test2"


  # TODO ambiguous name, intermediate stage
  # TOOD with --notebook option
  # TODO with "to" keyword

  Scenario: List Notebooks
    Given that I have 3 notebooks
    When I run "evernote list notebook"
    And the output should contain "1:"
    And the output should contain "2:"
    And the output should contain "3:"



