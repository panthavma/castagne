---
title: Castagne Input
order: 300
todo: 54
lastver: 53
---
<!-- TODO 55, 70 -->

<!-- TODO Numpad notation -->

# Castagne Input

Castagne's input system is quite intricate, as it is one of the core entry points of the engine. It is also one of the few parts that must be usable from outside of fights. This page will detail some of the key concepts, how to use it, and how it works internally.

As of the time of writing (v0.53), the input system is implemented, but buffering and motion inputs are not. Button press and release events are active for up to three frames by default. This part of the input will be revisited for v0.7-v0.8, with the aim of being able to handle high-frequency polling and be robust to online.

At the moment, analog input is not supported, although that is a future goal.

## Definitions: Physical Inputs and Game Inputs

Castagne Input is handled through two main types of inputs:

- **Physical Inputs** are defined by the user. They can have different types, and can be rebinded by the player. You can think of them as the actual buttons on your controller.
- **Game Inputs** are derived from the Physical Inputs and read by the game. They can be one of three types, depending on their nature. These are the actual events you can use in engine.

In addition to that, Castagne holds these inputs in a few different structures for use:

- **Input Layout** contains the physical inputs themselves. This is the base structure the others are derived from.
- **Input Map** hold the bindings for all the mappable game inputs. One is made for each device.
- A **Device** is a handle for a specific input source, like a keyboard or a controller. A device contains an Input Map, initialized from default bindings.
- The **Input Schema** hold all the game inputs, plus a few helpers to navigate them more easily. This is used as a reference for manipulating input.
- The **Input Data** is an internal format containing the actual input values.

## Input Types

Physical Inputs can have one of many types depending on their use:

- **Raw**: The simplest input, only defines a direct game input. Mostly meant as virtual buttons rather than actual player-facing inputs.
- **Button**: An on/off input that also defines Press and Release game inputs.
- **Axis**: A single axis input, with a positive and negative button. Will also define a neutral input as a button.
- **Stick**: A two-axis input, meant mostly for movement. Defines a lot of actions:
	- Buttons for each cardinal direction, called Left, Right, Down, and Up
	- Similar derived buttons, that are dependent on the facing of the entity. These are called Back, Forward, Portside, and Starboard.
	- Neutral virtual buttons, NeutralH and NeutralV.
- **Combination**: A combination of 2 or more direct game inputs together. These are activated automatically with the actual game inputs and vice versa.

Game inputs can instead have one of three types:

- **Direct**: These are the simplest, and simply copy the value obtained by polling.
- **Combination**: These represent the Combination physical inputs, and work by basing themselves off two direct game inputs. (Derived won't work)
- **Derived**: These are filled out by the engine depending on its state or the previous frames. Subtypes exist:
	- **Button Press**: Active when the button is just pressed.
	- **Button Relase**: Same for the release.
	- **Directional**: Copies a direction depending on facing.
	- **Direction Neutral**: Active if the two poles of its axis are not.

## Layout Configuration

The user must specify an Input Layout. This should be done through the Castagne Editor's Input Manager. The game inputs will be created automatically from there.

The editor allows users to create and organize physical inputs of various types. For each of them, they can also change:

- The *Game Input Names*. This is useful for compatibility and clarity.
- The *Default Bindings*. This is for setting the basic layouts, and can be done separately for keyboard and controllers.

<!-- TODO v54 v55 -->

At the moment (v0.53), to use the Base Casp files correctly, the main movement stick must keep its default names. The attack buttons shouldn't be changed, although this might change in Castagne v0.54.

Menu input may have a different layout specified, although that will be for v0.55.

## Device-Player Association

The association between an Input Device and a player is done outside the loop. Indeed, the main step function only takes the actual inputs in, and doesn't care about where they might come from. This enables mid-match controller changes, or hopping between replays, player control, and AI.

This may be specified in the BID to handle the basic association.

That part of the behavior is managed by `CastagneEngine.gd`, which provides some functions to change devices.

## Input Manipulation and Transformation

Inputs may be changed during the engine loop, as they might depend on the actual game state. This has two main cases: derived inputs, and fake inputs.

**Fake Inputs** are literally fake button presses and releases that can be made by the engine. This is mainly meant for AIs to be able to react based on what the game state is. This is limited to Direct and Combination inputs, and must happen before the Input Phase.

**Derived Inputs** are inputs dependent on other inputs (press and release events) and/or state (forward/back). They may come from various modules, and must be done in the Input Phase.

## Accessing Inputs from Outside the Engine

It is possible to access and poll inputs by accessing `CastagneInput` directly. This should be done from a Config Data handle.

While it *is* technically possible to use several CastagneInputs at the same time, they may interfere with each other.

## Rebindings

This is still in progress and will be implemented in v0.55.

## Standard In-Game Input Flow

<!-- TODO Local step, etc -->

Here is the full path of an input in the engine, in the standard case of two players fighting each other:

<!-- TODO v0.54 ai -->

- *Before the engine loop*: Raw Input is polled by `CastagneEngine.gd` based on the associated devices, and then given to the engine loop.
- *Frame Start*:
	- Will store the input from the previous frame.
	- Creates an Input Data from the Raw Input.
	- Distributes the Input Data to each entity needing it, based on its player.
- *Init Phase*: Will give the input to each new entity.
- *AI Phase*: Executes the AI Script, which might do fake presses. (Not implemented yet in v0.53)
- *Input Phase*:
	- *Before*: Other modules (physics) will fill out the various derived inputs.
	- *Input Phase*: Button Press and Release events are computed
- *Other Phases*: Input is now ready to be used.

## Alternative In-Game Input Flows

Other cases may happen, which can change input flow slightly. Here are some other examples:

<!-- TODO v0.8 v0.54 -->

- **Online / Rollback**: The newer input system is not currently handling that case, and will be revisited during the v0.8 update. Raw Input from the previous phases is recorded and compared to detect when rollback needs to happen.
- **AI**: Will be developed later in v0.6.
- **Replay**: Will be developed later in v0.6.
- **Training**: Will be developed later in v0.6.
- **Editor**: Input flow stays the same in editor, but some hooks may change or get input at various points as part of tools.

## Internal Structure

<!-- TODO InputLayout structure, Castagne Input vs Godot -->

This part describes in more detail how the input works at a technical level.

This part will be written later.

<!-- TODO -->
