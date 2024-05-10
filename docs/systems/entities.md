---
title: Entities
order: 100
todo: 54
lastver: 54
---

<!-- TODO v0.7 -->

# Entities

Entities in Castagne are an important core subject, and work has been done to make their use more integrated in the workflow. This page describes the concept as well as more advanced uses.

An entity represent an active character or object that has an impact on gameplay, as opposed to graphical effects or environments. They work using an internal state machine and variables. Entities are handled in parallel at every step of the main loop, to avoid race conditions as much as possible. This can make communication difficult, and is explained later on.

Entities are separated into two types, in order to improve performance and usability. The two types are:

- **Full Entities**, which represent full characters
- **Sub Entities**, which are used for projectiles and other independent parts of characters. They have a few particularities in their handling.

A character file will define one full entity, and can define a few sub entities. Each sub entity is linked to its full entity, and a player may have any number of full entities. One of the full entities of a player is declared to be the *main entity*, which enables additional behavior in specific cases.

## Full Entities and the Main Entity

Full entities represent complete characters, and their function is described in the rest of this documentation.

Full entities are created by the flow module at the beginning of a match, or by other full entities through the `CreateFullEntity` function. One full entity may only create more of its own type at the moment.
<!-- Clone entity ? -->

One full entity per player is considered the *Main Entity*, by default the first to be created by said player. The main entity is used for some specific behavior (like enabling easier targeting). This status can change during the game, for instance in team versus games where the player controls several characters.

Communication between full entities is limited and detailed below.

## Sub Entities

Sub entities are additional independent entities created by a full entity, and used to create projectiles for instance. Sub entities have additional restrictions upon them, but enable additional behavior.

Sub entities are defined inside the same character file as their owner. Their state names uses a ``Name--`` prefix, although this is hidden in the UI. They can be created with the `CreateSubEntity` function, which will also target the sub entity.

Sub entities have their own variables, states, and specblocks. One sub entity can extend another through their `Skeleton` property, with no value defaulting to `Base` (which is defined in a base casp file).

Sub entities' execution is a bit different from the usual, in order to enable some better performance and usability. These are:

<!-- TODO Init on reaction phase ? -->

- Sub entities are initialized using only their specblocks data, just after a full entity's action or reaction phase, meaning they get active on the same frame as they are created.
- Only a single pass happens for subentities, between the action and physics phases.
- The reaction of subentities to physics or other events is dependent on predefined triggers instead of fully controllable.

One major feature of sub entities is their relationship to their full entities, which enables additional behavior between them:

- Get and Set operations from the full entity to their own sub entity are instant (targeting another entity's sub entities still has a delay).
- Gets from the sub entity to ANY full entity are instant. Sets are delayed to the end of the phase.
- The full entity and their sub entities can target each other and get information in an easier way.

In other cases, the communication works as usual and is detailed below.

## Targeting

Targeting is a way to reference another entity, and thus be able to read or modify its variables. This part describes the targeting process, while the next section details how to use it.

Targeting is done through functions, which can use various parameters. Here are some examples:

- You can target opposing players' main entities using `TargetOpponentMainEntity()`
- You can target your own sub entities with `TargetSubEntity()`. The opposite can be done with `TargetOwner`.

Targeting is also done automatically at some points:

- When creating an entity, said entity will be targeted.
- During the attack callbacks, the opposing entity will be targeted.

Once a target has been acquired, you may also get its entity ID for later use with `TargetGetID()`, which you can then use with `TargetWithID`.

If a target is invalid (ie, it doesn't exist anymore), a warning will be issued and the `TargetInvalid` flag will be raised and the entity will target itself instead.

The target is reset at the beginning of every phase to what is known as the "saved target", which may be set using `TargetSave` and `TargetLoad`. On initialization, this target is the entity itself.

## Inter-Entity Communication

Once an entity is targeted, it can use this to read or alter data in it. Castagne puts some limitations on this in order to prevent too many weird bugs due to order of execution or race conditions, which results in some delays that are described here. Care should be taken in using these.

This is done through 'synchronisation points', where the state is applied. These happen after the init, action, and reaction phases.

Reading can be done using `TargetGet()` for variables, and `TargetGetFlag()` for flags. Values obtained this way reflect its state at the last synchronisation point. Any number of entities may read from a variable.

Writing can be done using `TargetSet()` for variables, and `TargetSetFlag()` for flags. Values set this way will be applied at the synchronisation point, after the changed variables are set. Two entities trying to write to the same variable should be avoided and will result in a warning, with the value used being the one given by the entity with the lowest ID.

A special case happens for entities who are not initialized yet, which happens when creating an entity. In this case, reads are not possible, but writes are and will be applied at the time of variable initialization.

> Please keep in mind that this isn't actually implemented exactly as described in the current Castagne versions, and will only happen in v0.7. No reading delay currently happens, so using this should be limited.

<!-- TODO Target Get Constants -->
