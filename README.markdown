Perl Error Sublime
==================

[PopClip](http://pilotmoon.com/popclip/) is a Mac OS X utility that will
allow you to display little menu icons that perform actions on highlighted
text.

![animated gif showing the extension working](http://i.imgur.com/1TZMe2Z.gif)

This extension allows you to highlight a Perl error in a Terminal and then
open the file in Sublime Text.  The cursor will be moved to the line the
error occured on.

Things like relative paths in the error message are handled.  With magic.
And AppleScript.  And lsof.  Honestly, you don't want to know.

Installation
------------

   * Install Popclip
   * [Download the extension](https://dl.dropboxusercontent.com/u/301667/popclip/PerlErrorSublime.popclipextz)
   * Double-click it
   * Confirm that you want to install the untrusted extension

Author
------

Written by Mark Fowler

   * http://twoshortplanks.com
   * http://github.com/2shortplanks/PerlErrorSublime.popclipext

Bugs
----

   * Doesn't work outside of Terminal.app
   * The files and paths obviously need to be local (i.e. this won't magically
     work over ssh)
   * Paths with spaces in don't work yet.  Pull requests welcome.

Further bugs, raise an issue on github.
