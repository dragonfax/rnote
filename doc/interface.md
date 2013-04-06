
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


TODO
====

This is what is unimplemented. As it is finished, feature tests are created for it.

describe "create note"

	with template
		notebook:
		title:
		tags:

	with --title
	with --content
	with --notebook
	with --tags

	with --create-only or --no-editor
		otherwise launches editor

	with --format

	with --watch

describe "show (note)"

	with "list" search parameters, multiple results, and an interactive result number

	with "list" search parameters, and a single result

	after a "list", with a result number

	with --format
		enml (untouched)
		txt (loses formatting)
		markdown (may lose some formating)

describe "edit (note)"

	uses EDITOR

	sets
	with --title
	with --content
	with --notebook
	with --tags

	with --no-editor

	given a --note title to find

	with a single result to edit

	with multiple results and and intermediate selection stage

	after a find

	with --format

	with --watch

describe "remove note"

	with --note and single result

	with intermediate stage

	after a find.

	asks for confirmation

describe "remove tag"

	with --tag

	no intermediate stage, no find

describe "list notes"
	"only lists note titles it finds, doesn't show contents"

	with --tags
	with --notebooks
	with --content
	with --title or --note


describe "list tags"

	simple

describe "rename tag"

	with --tag

	no intermediate or find

