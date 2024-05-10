---
title: Audio
order: 600
todo: 54
lastver: 54
---

# Castagne Audio

Castagne's audio systems, while relying on godot, have a few particularities to handle situations both outside of the game, and to handle rollback. This page details how to use said system.

At the time of writing (v0.54), the system stays simple and barebones on purpose.

## Sound Effects (SFX)

Sound effects are short samples that can be played during gameplay. Castagne's system works in this way:

- You set up a sound effect and its base parameters through the specblocks interface beforehand.
- You set parameters using the `Sound` family of functions.
- You play the sound using `SoundPlay`.

The sound is given to a callback which may be overriden.

## Music

Music is played automatically during matches and set using the interface in Castagne Config.

You can set a name and a loop for each track.
