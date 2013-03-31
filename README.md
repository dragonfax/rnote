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

Install it as a local gem. Its not on rubygems yet.

```
$ git clone git@github.com:dragonfax/rnote.git
$ cd rnote
$ gem build rnote.gemspec
$ gem install rnote-0.0.1.gem
```

Get yourself a developer token and login using that
`https://www.evernote.com/api/DeveloperToken.action`

`$ rnote login --dev-token 'S=sXXX:U=XXXX:E=XXXXXXXX:C=XXXXXXXX:P=XXXX:A=en-devtoken:V=2:H=XXXXXXXXXXXXXXX'`

Then your ready to go.

```
$ rnote find some string
$ rnote create --set-title "new note title"
$ rnote edit new note title
```

You could login with your username and password instead, but you'll also have to get your hands on a consumer key that works in production. That requires a bit more effort.


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