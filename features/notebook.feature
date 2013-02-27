Feature: Notebooks
  That I can manipulate notebooks.

  # lets be clear what our initial state is for all of these tests.
  Background:
    Given that I am logged in
    # please note that Evernote requires you to have at least one notebook at all times.
    And that I have only 1 notebook named "first notebook"

  Scenario: Create Notebook
    When I run "evernote create notebook 'test1'"
    Then I have a notebook named "test1"

    # TODO use --notebook option to name the notebook

  Scenario: Remove Notebook, with unambiguous name
    Given I have a notebook named "test1"
    # meaning we now have 2 notebooks, "test1" and "first notebook"
    When I run "evernote remove notebook 'test1'"
    Then I have 1 notebooks
    And I do not have a notebook named "test1"

    # TODO use --notebook

  Scenario: Remove Notebook, with ambiguous name
    Given I have a notebook named "test11"
    And I have a notebook named "test12"
    And I have 3 notebooks
    When I run "evernote remove notebook 'test1'" interactively
    And I type "1"
    Then I should have 2 notebooks
    And I have a notebook named "test12"
    And I do not have a notebook named "test11"


  Scenario: Rename Notebook, with unambiguous name
    Given I have a notebook named "test1"
    And I do not have a notebook named "test2"
    When I run "evernote rename notebook 'test1' 'test2'"
    Then I do not have a notebook named "test1"
    And I have a notebook named "test2"

    # TODO with ambiguous name and intermediate selection stage
    # TOOD with --notebook option
    # TODO with "to" keyword

  Scenario: List Notebooks
    Given I have 3 notebooks
    When I run "evernote list notebook"
    Then the output should contain "1:"
    And the output should contain "2:"
    And the output should contain "3:"



