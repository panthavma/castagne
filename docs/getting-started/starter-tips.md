---
title: Starter Tips
order: 8000
todo: 54
---

# Starter Tips

Here are a collection of some additional tips to help you get started!

## Adjusting animations

Animations can be pretty rigid as you need to open your 3D modeler or sprite editor to change them. An easier way to prototype or adjust if to take manual control of them through several functions.
- `AnimFrame` will show a specific frame of animation. That way, you can control exactly when to show what frame when, and is very similar to how sprite works.
- `AnimProgress` advances the animation by one frame. This can be used to pause an animation by not calling it or canceling using `AnimProgress(-1)` (like in charged moves), or to speed an animation up by calling it several times in one frame.
- `AnimLoop` allows you to loop an animation.

`Base.casp` allows you to change animations easily through the `Anim[State]` state scripts.

## Separating system mechanics

To scale your game, something really useful is to have the system mechanics in a different file, that is used by the others. This is a skeleton.

To set a file as your skeleton, you can either specify it in each file, or specify its path in the Castagne config (advanced core module).

## Specific hit / block animations

`Base.casp` allows you to specify some animations to use through attack flags. For instance, adding `AttackFlag(AnimTrip)` will play a tripping animation if set. The available animations are defined in the `AnimHitstun` script.

## Version control

It is strongly recommended to use version control on your game, as it will allow you to save your progress, share it, and be able to undo mistakes or check against an earlier version of the character.

Castagne only uses text files for the characters, and the rest is managed by Godot, meaning you can use any version control system. Git is recommended, as .gitignores are provided with the projects.
