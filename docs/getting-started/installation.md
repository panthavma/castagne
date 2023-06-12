---
title: Installation / First Start
order: 1000
---

# Installation / First Start

Download your OS version from [the Castagne website](http://castagneengine.com), unarchive it, and click on the godot executable. You're good to go!

Alternatively, download the dev branch version to get more features but less stability.

## Complete the setup

In order to be able to add new assets, you need to open Castagne in the Godot editor. To do that, follow this procedure:
- Move the Godot executable out of the project folder
- Launch the editor, and press "Import Project"
- Select "project.godot" in the root folder

From then on, you can now access the editor and add new assets! Press F5 to play, which will bring you to the editor.

> Some progress is being made to make those steps easier as time goes on!

## Upgrading Castagne

In order to update Castagne, just follow the procedure in the editor! Please backup your game before upgrading as a safety.

<!-- TODO Links -->
<!--If a new version of Castagne is out and you want to upgrade it, just follow this procedure:
- Backup or version your current project as a safety measure.
- Go to Castagne's [github page](https://github.com/panthavma/castagne) and download the latest version.
- Read the changelogs to see if anything needs your attention (mostly true for the early versions of Castagne)
- Replace your `castagne` folder with the new one.

If there were no breaking changes in the last version, you should be good to go!

You may also download the development version from the [dev branch](https://github.com/panthavma/castagne/tree/dev), but as the name implies it won't be tested as much.-->

## Setup from zero

If you want to start from a blank state, these are the steps you need to take:
- Go to Castagne's [github page]() and download the latest version.
- Put the `castagne` folder at the root of the project.
- Set the starting scene to `castagne/menus/starter/CastagneStarter.tscn`
- Add `castagne/Castagne.tscn` to the autoload list.
- Add `*.casp` and `*.json` to the export list.
- (Optional) Add `.castagne-local` to your SCM's ignore list. (Done automatically by Castagne if you use git).

This is what has been done for the Castagne generic release.

> Castagne is meant for Godot 3.
