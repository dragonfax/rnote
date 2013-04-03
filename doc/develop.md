Development
====

### Install it Manually

If you're playing around with the source, you can still build a gem and install that.

```
$ git clone git@github.com:dragonfax/rnote.git
$ cd rnote
$ gem build rnote.gemspec
$ gem install rnote-???.gem
$ cd
$ rnote login
$ rnote find
```

Of course you don't have to install it as a gem to use it. But your only able to access the Evernote sandbox when your running right out of the source tree. This is a safety measure. See the Auth Safeguards below.

```
$ cd rnote
# accesses sandbox only
$ bundle exec rnote find
```

Login Options
---

### Developer Token

Get yourself a developer token and login using that
https://www.evernote.com/api/DeveloperToken.action

`$ rnote login --dev-token 'S=sXXX:U=XXXX:E=XXXXXXXX:C=XXXXXXXX:P=XXXX:A=en-devtoken:V=2:H=XXXXXXXXXXXXXXX'`

### Username/Password

You could login with your username and password instead, but you'll also have to get your hands on a consumer key. That requires a bit more effort.


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
