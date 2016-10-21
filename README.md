<<<<<<< 76fe4206dca2a543c4c6448150c8cc67354d28d6
# GMAPN

## What is GMAPN?
GMAPN is a deathmatch mod for Quakeworld that focuses on user friendliness and lots of
=======
# What is Chilling Spree?
Chilling Spree is a deathmatch mod for Quakeworld that focuses on user friendliness and lots of
>>>>>>> Rebranded the mod.
game modes to try out. It is intended for having fun playing Quakeworld with new twists
of the game instead of playing the same three modes all the time.

Chilling Spree features fourteen game modes in total, nine of them which are unique to the mod compared
to KTX.

Lots of work has been made to create a whole new structure of deathmatch modding, it is
in fact rewritten from the ground up and has its unique style.

With a load of new features like GUI system, server side bot support and heapless of
game modes it is intended to be a casual mod that you can use to "just have fun"(tm).

For those that want to play custom maps but cannot decide what to pick, there is a
built in randomizer that selects ten maps that you can vote for.

## Installation
Right now the best way to install is by Git.

### Linux
Change into your Quake directory.
```
git clone https://github.com/molgrum/spree.git spree
cd spree
./updatebinaries.sh
make
./start_servers.sh
```

<<<<<<< 76fe4206dca2a543c4c6448150c8cc67354d28d6
### Windows
- Download the [zip](https://github.com/molgrum/gmapn/archive/master.zip) and extract into your Quake folder.
- Rename the folder to "gmapn".
- Download QCC [64-bit](http://triptohell.info/moodles/win64/fteqcc64.exe) or [32-bit](http://triptohell.info/moodles/win32/fteqcc32.exe) (put into gmapn directory)
=======
## Windows
- Download the [zip](https://github.com/molgrum/spree/archive/master.zip) and extract into your Quake folder.
- Rename the folder to "spree".
- Download QCC [64-bit](http://triptohell.info/moodles/win64/fteqcc64.exe) or [32-bit](http://triptohell.info/moodles/win32/fteqcc32.exe) (put into spree directory)
>>>>>>> Rebranded the mod.
- Download server [64-bit](http://triptohell.info/moodles/win64/fteqwsv64.exe) or [32-bit](http://triptohell.info/moodles/win32/fteqwsv32.exe) (put into quake directory)
- Download optional PK3 [here](http://triptohell.info/moodles/junk/gmapn.pk3) (put into spree directory)
- Run QCC exe and winquicker.bat

Happy gibbing!

## Wiki
Our wiki is located [here](https://sourceforge.net/p/gmapn/wiki/Home/).

## How to test

### Servers
- Testing server is located at *fr.besmella.com:2901*.
- Connect with FTE or Fodquake preferably.

### Chat with us

## Chat with us
- **#spree** @ [Quakenet](https://webchat.quakenet.org/)
- **#beta-testers** on [Discord](https://discordapp.com/)

## Differences from KTX

### Server side
- Built for FTESV. Unfortunately MVDSV cannot be supported due to technicalities but if the MVDSV team would like to cooperate we will gladly code support for it.
- Written (almost entirely) from scratch in QuakeC.
- Server side "antilag" which works better and more precise than MVDSV.
- Frikbot support built in. This is mostly for testing purposes but we would really like to improve this AI logic with someone who is wiling to help us.
- Statistics are saved when you play making a history of kills and deaths using your nickname as identifier across disconnects.
- Practice mode is redundant, all doors trigger etc are reset on match start.
- Server cvar key system to configure the mod, very customizable in itself with keys for almost anything.
- Rulemaker system, whoever connects first gets to set the rules of the game to be played. This status is preserved across map changes as well.

### Client side
- CSQC is planned for future releases, client side modding makes possible for predictions to be made.
- Menu system instead of console commands, control the rules and setup with cvar keys.
- Get a random list of custom maps when voting for one.
- Faster loading of commands to the client.
- Some lightstyle eyecandy when a match is about to start, check it.
- Possibility to download .loc, .cfg and .lit from the server.

### Administration
- Simple installation.
- FTEQCC is in Debian/Ubuntu repositories but is old, try to use the one at triptohell instead.
- Same goes with FTESV, use triptohell.
- For Debian admins we noted that SQLite support needs this command:
```
ln -s /usr/lib/libsqlite.so.0.8.6 /usr/lib/libsqlite3.so.0
```
- .ent files are used for map modifications such as quad on Aerowalk and removing spawn on End.

## Testing

### Server issues
- Try to play on the server and get it to become inaccesible, then message a dev.
- Duel arena becomes an endless match when played for a longer time, make it reproducible.
- Try the bots and leave feedback on ideas to improve them (they need improvement we know).

### Preservance

#### SG/SSG
- The spread has been modified to make every bullet an individual damage inflictor, see if this is problematic in any way.

#### LG
- Test the LG on povdmm4, does the percentage differ from KTX?
- Is the blood spawning more on this mod?

### Enhancement
- Try out every mode, see if you find any flaws or ideas on how to make them better.
- If you have design ideas we would love to hear them.

### Deployment
- Test out to deploy it on a machine by using the instructions like described above.

## Current progress

### Duel
- Tested and works.

### 2on2
- Not extensively  tested.

### 4on4
- Not extensively tested.

### Duel Arena
- Issues with spectating players not getting disconnected when game is in progress, reproduce this and file a report so we can fix it.

### Freeze Tag
- Not extensively tested.

### Hide & Seek
- This mode is mod specific, which means it is just a mock-up of a mode that needs suggestions.

### Domination
- Teamplay with control points.
- Needs info_controlpoint on all maps. Feel free to make .ent files, test and give coordinates of new ones!

### Rover
- Not extensively tested.

### Kill the King
- FFA style mode.
- Test if the timelimit is okay.

### Free For All
- Not extensively tested.

### Capture the Flag
- Needs flag positions to be implemented, you can do this by adding them into a .ent file if you want to help out.
- Known issue with team spawns not properly implemented.

### Head Hunters
- FFA style mode.
- Test if the timelimit is okay.
- NOTE you always gib in this mode.

### Last Man Standing
- Not extensively tested.

### Cooperative
- Tested and does work, there may be issues though.
- Idea about starting on any map and having the previous progress autocompleted.

### Race
- NOT IMPLEMENTED YET. If there is need for anything better than KTX feel free to drop suggestions.

## Help out

### Bots
Bots are in a very poor state, being Frikbot and all. Help out with AI!

### Bugs
Right now the most awkward bug is the vwep models being jerky and not displayed correctly. Reproduce this and file an issue.

### Altars & Controlpoints
We need coordinates for some maps of your choosing, place **one** info_altar in Head Hunters, place **several** info_controlpoint in Domination.

### Game modes left to test
These are: Last Man Standing, Freeze Tag, Domination and Rover. Four modes that have not been tested much.
