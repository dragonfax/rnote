
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
with the 'evernote' command. And doing so by referencing other step definitions.
