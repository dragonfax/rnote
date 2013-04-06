Status
====

This project is not ready for primetime. I'm using it myself daily for personal note taking, but it still has a lot of holes in its interface.


Pay Features
----

NOTE: no Evernote 'pay' features are supported or re-implemented by this interface.



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


### Verb x Noun Matrix

What completed so far.

<table>

<tr><td></td>        <th>note</th>    <th>notebook</th> <th>tag</th> </tr>

<tr><th>find</th>    <td>X</td>       <td>N/A</td>      <td>N/A</td> </tr>
<tr><th>show</th>    <td>X</td>       <td>N/A</td>      <td>N/A</td> </tr>
<tr><th>edit</th>    <td>X</td>       <td>N/A</td>      <td>N/A</td> </tr>
<tr><th>create</th>  <td>X</td>       <td></td>         <td>X</td> </tr>
<tr><th>remove</th>  <td>X</td>       <td></td>         <td>X</td> </tr>
<tr><th>rename</th>  <td></td>        <td></td>         <td>X</td> </tr>
<tr><th>list</th>    <td></td>        <td></td>         <td>X</td> </tr>

</table>


