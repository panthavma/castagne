---
title: Engine Loop
order: 200
todo: 54
lastver: 54
---

# Engine loop

This page explains a simplified version of Castagne's main loop, meant to help users wrap their head around what is going on. The full version is in the [Engine Core page of the advanced documentation](/advanced/enginecore).

## 3 Main Steps

A Castagne loop can be simplified to 3 main components:

- The **Action Phase**, where most of the behavior happens. This is where most behavior is executed and what will matter most of the time. This is also where you declare attack and hitboxes.
- The **Physics Phase**, which is done by the engine and handles movement and hit detection. Callbacks happen, and then...
- The **Reaction Phase** acts upon the results of the previous phase, mostly by doing Transitions.

This gives a direct flow to the engine and ensures there is no port priority or weird order dependent behavior, which makes results more stable. In most cases, this will be transparent, but in some cases bugs can be hard to understand if you don't know how it happens.

## My actions are not registering ?

Each state script is executed for each phase, but not every function is executed in every phase. In most cases, this is convenient and you don't need to think about it, but sometimes a value might not be set in time for a transition, for instance. Let's see an example:

```
Hitbox(0, 10000, 0, 10000)

V_AttackHasHit:
	Set(X, 1)
	Transition(State2)
endif
```

Here, the Set will never be called. Let's do it step by step:

- The hitbox is declared in the action phase. The attack has not hit yet, so the branch is ignored.
- Physics phase happens, and a collision is found.
- Reaction phase starts, the hitbox is ignored since it's only in action phase.
- `_AttackHasHit` is now true, so we go in the branch.
- Set is ignored, because we are in the Reaction phase
- The Transition call is made, since we are in the Reaction phase
- At the end of the frame, we change the state, meaning the Set never had the chance to get executed.

This can be hard to spot, and several ways exist, but the simplest way to ensure something happens is to force execution during a specific phase, using P branches. Here is the example fixed:

```
Hitbox(0, 10000, 0, 10000)

V_AttackHasHit:
	PReaction:
		Set(X, 1)
		Transition(State2)
	endif
endif
```

All functions in the PReaction branch will be executed during Reaction phase only, regardless of their individual settings.

## New entities, inputs, and AI

While this simplified view is sufficient in most cases, it is good to know how some additional parts are handled. The engine will do three phases in order before going to the action phase:

- The **Init Phase** is called for every new entity, and will execute that entity's Init state script, as well as set its variables to their default values.
- The **AI Phase** is called once per player on their main entity, and allows for fake button presses when controlled by the computer.
- The **Input Phase** happens once per player and manages the derived inputs.

Once again, in most cases this will be transparent and not needed.

## Freezing and Halting

There are two ways to stop an entity from moving, by manually entering the Freeze or Halt phase:

- The **Freeze Phase** is called on individual entities, and will "pause" execution for a little bit only. This is not a global pause, as it will only affect said entity. The frame counter will not advance, but only some functions (mainly hurtbox) are executed. This is meant for hit reactions mostly.
- The **Halt Phase** is a global function instead, where one entity can request a pause of the whole game except it. This is mostly meant for cutscenes and super flashes.
