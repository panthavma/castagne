---
title: Engine Flow
order: 50
todo: 53
---

This page will detail the core loop of the engine, and details how a frame is executed in Castagne.

<!-- TODO v0.53 Concepts -->

## General Concepts

### Phase

There are two types of phases: Script Phases, and Internal Phases. The loop is separated into a few of them.

Script Phases include the execution of a state script. They follow this structure:
- Module callbacks (general, then entities)
- Execute the state script for said phase for each entity.
- Module callbacks (entities, then general)

Each state script is compiled for each phase. Functions know which phases they are executed in by default and which states they may be executed in.
All entity operations are conceptually done in parallel (and may be physically done in parallel in the future).

Internal Phases only involve modules, and can follow their own structure, which includes similar callbacks to Script Phases.

### State Handles and memory types

All memory is accessed through a StateHandle. It allows access to the memory stack and other useful data (like config and instanced data).
All variables must be stored in the memory stack, as this is what will allow rollback to happen.

The type of data is as follows:
- **Memory Stack**: This represents the current state of the game (position, etc). This is the main part that changes each frame, and can be saved to rewind.
- **Config Data**: Read-only data specified at the start of the engine run. This will configure the engine and modules and may be changed through the Castagne Editor.
- **Instanced Data**: Instanced nodes used by Godot. Include stuff like models or sounds.

## Application and Engine Start

At the start of the application, all modules found (the castagne standard modules and the user supplied modules) go through `CastagneModule.ModuleSetup`. This is the time at which the modules will specify all their variables, flags, and functions, but won't set up anything game specific. Please see the [module structure page](../modulestructure) for details.

By default the engine will be loaded by the *Castagne Starter*, the *Castagne Editor*, or *Castagne Menus*, but you may also start it manually. This is done through the `CastagneGlobal` interface with `Castagne.InstanceCastagneEngine`. It takes **Battle Init Data** and an optional **Config Data** if not using the main one.

The *Castagne Starter* is a development tool that can redirect the user to precise situations. The main uses are going into the *Castagne Editor* (default option) or start the game normally through the *Castagne Menus* (default when not running in edit mode). You may also use it to quickstart into a Training mode or Local battle, which is mostly used for engine development. For instance, on my local development setup, I added a way to start the Castagne Editor with the individual default config files for the genres.

**Battle Init Data** is a data structure containing the info needed to setup a specific match, including which characters are in play, on which stage, etc. This is specified by modules, but is mostly the prerogative of the flow module.

<!-- TODO v0.53 -->
TODO: Go back here once the flow module is more defined

The engine initialization will manage the creation of the memory stack, copies the variables specified at module initialization to the memory stack, and set up the modules for use through the `CastagneModule.BattleInit` callback. The main user of this is once again the Flow module, as it is the one that will create the first characters.

Then, the engine will run some frames with empty input before showing anything, in order to allow some of the base setup to be done.

## Engine Main Loop

The main loops takes two inputs each tick: the **preivous memory stack**, and the **raw input for the frame**, and will return the **new memory stack**.



The engine will then execute the **(0.) Memory Internal Phase**, which is the only one always guaranteed to be executed. Its role is:
- Copying the previous memory to make the new one.
- Altering the frame ID
- Using the `FramePreStart` module callback
- Choose the correct loop type for this frame.

This section will describe the **Standard Loop**, the others are specified just after it.



The **(1.) Init Script Phase** will then create and initialize entities. This phase will only act upon entities waiting to be initialized. This phase is also particular as it can be executed cyclically: an entity in Init phase may create another new entity in the same frame. A safeguard is in place to avoid softlocking the engine through an infinite loop. This is also where entities are destroyed as needed.



The **(2.) AI Script Phase** happens next, and allows the custom AI to simulate inputs and manage AI states. This is the last moment at which fake inputs may be given by modules, which is used by the training mode for instance. Please see the relevant pages (TODO) for more details. (In development at time of writing)

<!-- TODO: Who execs AI and Input ? -->

The **(3.) Input Internal Phase** takes over then, and will enrich the input to make it more usable.
- The primary (buttons) and secondary (macros) inputs update each other.
- Module callbacks are made to handle tertiary inputs like Forward/Back.
- Inputs are enriched by managing buffers, detecting press/release events, and handling motion inputs.

Please see the relevant pages (TODO) for more details on this system. (In development at time of writing)



Then, the main phase, the **(4.) Action Script Phase**, which is executed by all active entities. This is the one where most functions will be executed, and will handle most computations. Some events, mostly physics (movement, hitboxes) and transition related are buffered instead.

In parallel, the **(4b.) Freeze Script Phase** is executed for currently frozen entities instead. This happens mainly when you got hit by an attack, and pauses the frame advances for a bit. Hurtboxes are still computed, and the character may be hit.

<!-- TODO subentity init and action -->

The **(5.) Physics Internal Phase** then happens, which has a similar callback structure to script phases, but will use a specific callback to the Physics module instead of script execution. This is where movement is managed, as well as hit/hurtbox interactions are detected. Please see the relevant pages (TODO) for more details.

<!-- TODO: Update when physics is redone / final-ish -->



Finally, the **(6.) Reaction Script Phase** manages the results of the physics. This is where entities may react to the hits taken or given, and manage state transitions, which will be applied at the end of the frame through module callbacks.

<!-- TODO Subentity init ? -->


At this point, the new memory stack is complete and returned, ready to be saved if needed, and reused as the basis of the next tick.

<!-- TODO: Update this section after the AI module works -->

### Halt Loop and Manual Phase

One entity may **Halt** the execution, giving it full control for a given number of frames. When a halt request is received, the next frame will be a special Halt loop instead.

During a **Halt Script Phase**, only the current initiating it has their script executed. The main use is meant for super flashes and cutscenes, where the gameplay is completely paused. This is opposed to Freeze phase, where only a single entity is frozen and the game continues as expected.

If two or more entities want to halt execution on the same frame, the calls will be queued one after another one at a time. This is done in order of entity ID.

Another particularity is the **Manual Phase**. This is not a phase per se, but a special compilation option which is used at times to force execution, mostly in P branches. This is an internal tool more than a conceptual phase.

## Entity Management

- how entities are added
- instanced data management

<!-- TODO: Update this when implementation is cleaned up -->

## Engine Stop

When the match is ended, a callback is made


<!-- TODO: Update when done -->
<!--
## Design Philosophy

The main loop is that way to answer multiple constraints:

- **Parallelism**: The entities must be able to be run in parallel to get enough performance for rollback on more complex scenes. This also avoids some bugs that depend on order of operations (like Painter's Unblockable). This also affects buffering of some operations.
- **Flexibility**: Modules provide everything, and as such they need to be able to act at each defined points, hence the more complex structure.
- **Input and AI**: Must go among the first to be able to be acted upon.-->
