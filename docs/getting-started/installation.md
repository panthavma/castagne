---
title: Installation / First Start
order: 1000

template: docpage.hbt
pathtoroot: ../../../
---

# Installation / First Start

To run Castagne, you will first need to download [Godot](https://godotengine.org/download). The most recent Godot 3 version should be good.

<!-- TODO Link and images -->
Then, the next step would be to download the [Castagne Empty Project]() from the official Castagne website or github.

Once done, unarchive both, and launch the Godot Editor. Select "Import Project", and navigate to `castagne-empty-project/project.godot`. You should now have your project open and ready to roll!

## Upgrading Castagne

<!-- TODO Links -->
If a new version of Castagne is out and you want to upgrade it, just follow this procedure:
- Backup or version your current project as a safety measure.
- Go to Castagne's [github page]() and download the latest version.
- Read the changelogs to see if anything needs your attention (mostly true for the early versions of Castagne)
- Replace your `castagne` folder with the new one.

If there were no breaking changes in the last version, you should be good to go!

You may also download the development version from the [dev branch](), but as the name implies it won't be tested as much.

## Setup from zero

If you want to start from a blank state, these are the steps you need to take:
- Go to Castagne's [github page]() and download the latest version.
- Put the `castagne` folder at the root of the project.
- Set the starting scene to `castagne/menus/starter/CastagneStarter.tscn`
- Add `castagne/Castagne.tscn` to the autoload list.
- Add `*.casp` and `*.json` to the export list.
- (Optional) Add `castagne-local` to your SCM's ignore list. (Done automatically by Castagne if you use git).

This is what has been done for the Castagne Empty Project.
