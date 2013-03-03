
Philosophy
==========

The features for this project, should act as documentation of the command line arguments an the interface.
So its important that they actually contain the command line used for each test.

These features are also made to run against the public Evernote Sandbox.
So they probaly shouldn't be launched by an automated system. But manually launched is fine.

All this combines to give us a few odd steps in the features. That normally would be against best Cucumber practices.


All Steps, No Code
------------------

Ideally I'd like all of the steps in these features to be described in terms of other steps.
Since we're working with a command line application here, the scope of operations is pretty limited.

* running commands
* verify exit status
* verifying output
* entering a line of input here and there.

So the step code shouldn't actually be using the modules in this gem directly. But instead interacting soley
with the 'rnote' command. And doing so by referencing other step definitions.


Evernote Issues
---------------

These tests were designed to verify the user interface during development.
The intention is to run them against a live Evernote sandbox account.

There are some operations Evernote doesn't let you do from the API which 
makes it impossible to establish a perfectly clean environment before each test run.

You can't
* expunge items ('delete' operations only moves items to the trash)
* delete notebooks
* revoke auth keys (the account will fill up with keys after lots of auth tests)


Aruba Issues
------------

Some issues with Aruba.

= Interactive Processes

You have to wait for an interactive process to finish. You can do this by putting in a step referencing the exit status.
I'd prefer to leave these out of the steps, as the user doesnt' care what the exit status is,
and it just makes the scenarios needlessly verbose. But its necessary, and I the alternative choices are more verbose.

There are other timing issues with interactive processes as well. You can't just start it, and dump input into it, and then wait for it to finish.
You should, instead, put in wait operations for the prompts you expect. Before entering your responses with 'And I type "???"'. 
I haven't investigate the issues further.




