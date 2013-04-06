
The modules in this directory represent what commands that are available on the command line.

### Command Aliasing

This doesn't just mean the list of verbs. But because of command aliasing, we'll have nouns listed here as well.  Letting you do such things as

```
$ rnote note create
```

as well as

```
$ rnote create note
```

Whichever you prefer.


### Lazy Loading

These files here should be small and should load quickly. Eventually we're have them defer the 'require' of the large "business logic" modules until you've actualy chosen and started to execute a command. This should improve the performance of the tool a bit.