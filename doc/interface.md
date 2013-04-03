
Interface
====

Here I describe the philosophy behind the available commands.

Nouns & Verbs
----

The subcommands are arranged into pairs of nouns and verbs. First you specify a verb, then you specify a noun.

`$ rnote find note`

But most verbs will assume a default noun of 'note' so you can cut it short.

`$ rnote find`

#### Nouns
* note
* notebook
* tag

#### Verbs

##### verbs that take nouns
* find
* show
* edit
* create
* remove
* rename
* list

##### verbs that act alone
* who - show who you're logged in as
* login
* logout

### Example Commands**

```
$ rnote login
$ rnote show note 
$ rnote edit note <note title or search>
$ rnote create note
$ rnote remove note <note title or search>
$ rnote logout
```

### Interactively Selecting a Noun (Note)

If any command finds multiple matching notes, it will ask to which note you refer. You can also do a search before such a command, and then specify a search result item to operate on.

```
$ rnote find <search string>
<<search results displayed>>>
# to edit the 3rd note from the search results
$ rnote edit 3
```
