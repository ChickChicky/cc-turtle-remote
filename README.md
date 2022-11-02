# CC:Tweaked Turtle Remote

A long time ago, I wrote this code inspired by a project by [ottomated](https://github.com/ottomated). For some reason it stopped working and I fixed most issues, although I'm pretty sure there is still plenty of them.

There are two parts, a server and a client, which are in the [remote](remote/) and [turtle](turtle/) folders. All the files inside [turtle/](turtle/) have to be placed into the root of a CC:Tweaked turtle, or downloaded directly with `wget run https://raw.githubusercontent.com/ChickChicky/cc-turtle-remote/main/install.lua`.
# How to use this

Firstly, you'll need to run `npm install` in [remote/](remote/), and then you can run `node main.js` in the same directory, you should see *`SOME DATE`*` - Listening on port 8080`.

Then, you can turn on your turtle, and there should be `remote control slave` written at the top.

The last thing is to connect to the remote, to do this simply head over `http://localhost:8080` in your web browser. You now need one final step, look at your console and search for a line like this: `SOME DATE - New peer connected, assigning id `*`X`*. Now simply modify the URL you typed in earlier to `http://localhost:8080?id=`*`X`*, replacing *X* with the ID of the turtle given by the console.

You can now move around with the blue buttons, dig up, down, and up front with the red buttons. You have three other panels, one that shows you some info about where it is and what blocks are around it, one that allows you to send commands to the turtle, and at the bottom a 3D view of how the environment of the turtle looks like.

In order to set back the position of your turtle, you can write `turtle._forceSetPos(X,Y,Z)` (replacing X,Y,Z with the actual turtle's position), and hit the *send* button. If you need to reset the orientation of the turtle, you can send `turtle._forceSetOrient(D)`, with *0* being north, *1*: *east*, *2*: south and *3*: west.