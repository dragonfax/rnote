
Editing Formats
======

The only format available for now is plain txt.

Markdown format is expected to be added eventually.

Converting Between Formats
======

Converting between your chosen editing format and ENML (Evernotes internal format) is done
every time the file is saved.

The philosophy for format conversion is pretty simple.

* Rnote expects to be the primary editor for content created in Rnote.


Converting Between Our Own Formats
----

We expect perfect conversion when dealing with only our own formats.

When converting from our own format (say txt or markdown) to save on Evernote, 
then we expect the content to be convert back to our own format before being edited.
And as such we must ensure that such conversion ( format -> enml -> foramt ) is perfect,
i.e. nothing is lost or added to the 'format' content through such a conversion.

If something were added through such a conversion, it might be added every time we save the file to evernote.
And as such create an ever increasing a note. This sometimes happens with such things as whitespace.

**NOTE:** This all assumes that Evernote won't modify the xml we upload to it, 
and instead will simply reject that xml if it doesn't like it.

Dealing With Other Editors
----

If the content created in rnote is further modified in another Evernote client,
then we don't strive to keep that added content perfectly formated.

Furthermore, no attempt is made to keep the formatting created in other editors.
Its assumed that if you start editing a note using Rnote, then it will be
the primary editor for that note afterwards.




