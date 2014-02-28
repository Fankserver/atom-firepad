# atom-firepad

This package for Atom adds collaborative editing support via [Firepad](http://firepad.io).
Firepad is an OT library that implements collaborative text editing using [Firebase](https://www.firebase.com).

To get started with this package, first install it. Then, open a new **empty**
file to start collaborating via the `firepad:share` command
(you can trigger this command via Cmd+Shift+P):

![Step 1: Share Command](http://i.imgur.com/B0JhyLC.png)

Next, you'll be asked to enter a string identifying this session. All users
who enter the same string while sharing a document will see the same contents:

![Step 2: Enter Session Name](http://i.imgur.com/dIyCFXq.png)

Finally, you can use the `firepad:unshare` command to stop collaborating.
