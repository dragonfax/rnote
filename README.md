RNote
====

A command line interface to Evernote. 

Written in ruby, using Evernotes Oauth and Thrift based APIs.  Packaged up as a gem, but designed for use as a command line tool, not as a programmatical interface to Evernote.


Interface
====

Nouns & Verbs
----

The subcommands are arranged into pairs of nouns and verbs. First you specify a verb, then you specify a noun.

`$ rnote find note`

But most verbs will assume a default noun of 'note' so you can cut it short.

`$ rnote find`

**nouns**
* note
* notebook
* tag

**verbs**
* list
* find
* show
* edit
* create
* remove
* rename

**Example Commands**

```
$ rnote show note 
$ rnote edit note <note title or search>
$ rnote create note
$ rnote remove note <note title or search>
```

If any command finds multiple matching notes, it will ask to which note you refer.

You can also do a search before such a command, and then specify a search result item to operate on.

```
$ rnote find <search string>
<<search results displayed>>>
# to edit the 3rd note from the search results
$ rnote edit 3
```

Settings
----

The settings files are located in `~/.rnote`. But there are no user modifiable settings yet. 

Pay Features
----

NOTE: no 'pay' features are supported or re-implemented by this interface.

Status
====

This project is not ready for primetime. I'm using it myself daily for personal note taking, but it still has a lot of holes in its interface.  Its not available as a gem as its not ready for version 1.0 or regular consumptions yet.

Try it out
----

### Install the gem

```
$ gem install rnote
```

### Install it Manually

If you're playing around with the source, you can still build a gem and install that.

```
$ git clone git@github.com:dragonfax/rnote.git
$ cd rnote
$ gem build rnote.gemspec
$ gem install rnote-0.0.1.gem
```

Of course you don't have to install it to use it. But your only able to access the Evernote sandbox when your running right out of the source tree. See the Auth Safeguards below.

```
$ cd rnote
$ bundle exec rnote find
```

### Login and Get Going

Get yourself a developer token and login using that
https://www.evernote.com/api/DeveloperToken.action

`$ rnote login --dev-token 'S=sXXX:U=XXXX:E=XXXXXXXX:C=XXXXXXXX:P=XXXX:A=en-devtoken:V=2:H=XXXXXXXXXXXXXXX'`

Then your ready to go.

```
$ rnote find some string
$ rnote create --set-title "new note title"
$ rnote edit new note title
```

You could login with your username and password instead, but you'll also have to get your hands on a consumer key that works in production. That requires a bit more effort.


Testing
---

There are a lot of system integration tests here that log into the actual Evernote sandbox and fiddle around with notes.

The cucumber/feature tests in feature/ and the integration tests in test/integration both use sandbox users to perform their tests.

### Secrets File

The credentials are all provided in the file test/integration/secrets.rb. See the secrets.rb.example file for what it should look like.

### Developer Token

The auth tests verify logging in with a developer token. You can get a sandbox developer token by going here https://sandbox.evernote.com/api/DeveloperToken.action

A developer token it fully authenticated all by itself. It doesn't require a username/password or a consumer key.

### Consumer Key

The auth tests check logging in with a username/password pair as well. But using a username and password requires having a consumer key (in sandbox).

You can get a consumer key by going to http://dev.evernote.com/start/core/authentication.php and by clicking on the green 'API Key' button in the upper right of the page.


### Running The Tests

With `secrets.rb` setup properly, you can run the tests directly on the command line or using your IDE.

```
$ ruby test/integration/auth_test.rb
$ ruby test/unit/converter_test.rb
$ ruby test/unit/waitpid_test.rb
$ cucumber feature/auth.feature
$ cucumber feature/note.feature
```

### Auth Safeguards

There are no tests that log into production Evernote. But to ensure this can't happen by accident, there are a few safeguards in place.

* the file `lib/rnote/environment.rb`
    This file overrides settings in the tool.
    This file is not provided in the gem, and thus doesn't effect a gem-installed copy of the tool.
    Without this file in the library load path, the tool can access both sandbox and production, but cannot run tests.
    * forcing it to use the sandbox only
    * allowing tests to run.
    * using a different directory to store cache and auth files.
* all tests of the command include --sandbox
* all tests check that the `environment.rb` was loaded
* always use a different username and password in sandbox, than production.

NOTE: Be careful not to use your production Evernote username or password to ensure the tests can't possibly corrupt your existing Evernote account. Always create special test users with usernames and passwords different from your own production Evernote account.

What Works
---

* login/logout (w/ username,password and consumer key, or developer token)
* creating and editing notes
* searching for notes
* deleting notes

Take a look at the feature tests to see whats been implemented, and example syntax.

What Doesn't Work
---

Anything listed in 'interface' but that doesn't yet have a feature test written for it.

TODO
---

* [ ] Anything from 'interface' not yet implemented
* [ ] using the 'revokeLongSession' api method to implement a proper 'logout'
* [ ] additional format options (only txt for now, and markdown isn't really implemented)
* [ ] the entire tool is too slow
* [ ] improve search result display formating