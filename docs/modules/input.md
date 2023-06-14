---
title: Input Module
order: 300
todo: 53
---

Input management. Will be filled out for v0.53.

## misc notes for the docs







## Design Proposal

### Notes

- Concept
	- Creates and handles inputs for each player, in collaboration with the flow module and/or general Castagne
	- Cover regular inputs, macros, and the like
	- Flexibility
		- Need to work in menus
		- Rebindable from a lot of places (ingame, menus, CSS)
		- Need to be able to change from one to the other during gameplay
		- Needs to be given by a replay, online, or an AI
	- Motion Inputs and buffers to be handled later during v0.7/v0.8
	- Handle the move canceling directly


### Technical Proposition

- **Overview**
	- Input storage is separated from the way it's polled.
- **Input Definition**
	- Three categories of input can be defined
		- *Primary Inputs*: Physical buttons directly bindable by the player. Examples: 8 way direction stick (left, right, up, down), basic attack buttons (A, B, C)
		- *Secondary Inputs*: Button combinations / macros. May be binded separately or not. Examples: Throw macro (A+B)
		- *Tertiary Inputs*: Actions affected by game state and/or derived from the previous ones. Examples: Forward - Back direction, A just pressed.
		- Primary and secondary inputs are linked and determined first. If the basic buttons are pressed as primary inputs (A, and B), the corresponding macros are also active (A+B throw). This also applies in the opposite sense (pressing the A+B macro will also register the physical buttons).
		- Only primary inputs are stored and transferred over the network / replays.
		- AIs and other systems may press primary or secondary inputs instead of the player.
		- The combination of all inputs is known as the **input map**.
	- Several types of inputs exist to be added by the user, and provide several primary, secondary, or tertiary inputs.
		- *Raw*: a very basic input that is not meant to be added directly most of the time, but to be precise.
			- Primary inputs: X
			- Analog: Can be retrieved as a value between 0 and 1000 (although the internal representation may have less precision)
		- *Button*: A binary input
			- Primary Inputs: X
			- Tertiary Inputs: XPress and XRelease
				- These are active for a specified amount of frames after the event occured.
			- Analog: Can work from an analog input using a threshold, or be retrieved as an analog input directly.
		- *Axis*: Linear input with from -1 to +1
			- Primary inputs: +X, -X
			- Tertiary inputs: Press and Release, and Neutral
			- Same as button for both
		- *Stick*: Input along axises, going from -1 to 1, along two or more dimensions
			- Primary inputs: All directions
			- Tertiary inputs: Neutrals, full press
			- Analog: Can also normalize the input
		- Internally, Axises are two buttons, and sticks are two or more axises. Their individual actions are also added to the input map
		- The button name displayed can be different than the internal name.
- **Input Schemas**
	- Represent default configurations for keyboard and controller, as well as the custom ones
	- A controller/device is associated with one or more input schema
		- The multiplicity is intended more for keyboard than controller
	- These are used to initialize and change the internal godot input configurations, which are then used by the input module
- **Input - Game Connection**
	- Done by the input module itself by injecting inputs before the AI phase.
	- Inputs are polled from the Input module, accessible through ConfigData
		- Considering we need to access it in menus, there is a need for some kind of input to be always active
		- At the same time, having it setup in ModuleSetup will make it troublesome if there is an input module variation active
		- That could be solved by having some sort of generic data storage INSIDE of ConfigData
		- At the same time, it's not critical at this stage, but good to think about at least
- **Input-driven state transitions**
	- Alternative way of doing transitions to the `Transition` method
	- Checks for an input and will transition to it if it fits.
	- Can be controlled manually, but by default will happen automatically at the Transition phase
	- The functions will add checks, and need to be executed each frame.
	- Can handle direction + buttons.
	- Is going to be the method for motion inputs.
	- Additional limitations (whiff/hit/block and chain limits) are handled by the Attack module. This interface is meant as an additional raw system.
- **Non player-driven presses**
	- During gameplay, inputs may be injected to the various players.
	- Interface only allows primary and secondary inputs to be sent.
	- Input resolution is done after the AI phase, before the init phase.
	- AI: AIs may add inputs during the AI phase and scripts.
	- Replays: primary inputs are stored in a separate file and fed to a character during the AI phase.
	- Training: Inputs are provided either by a module, or specific AI scripts.
- **Motion Inputs and Buffers**
	- Coming at a later time, with v0.7 - v0.8 as it might be affected by both the rewrite and online.
	- To reduce expense, inputs may be lazily evaluated.
- **Common scenarios and solutions**
	- Simple fighting game
		- Input schema is defined in the editor and may be changed by the player
		- Flow module calls on the input module to initialize everything as expected.
	- Menu Navigation
		- Devices are gathered from the input module, accessible through the global singleton
		- Could maybe add a simpler way to check for all inputs at the same time ?
	- 4 player
		- Each player will initialize as usual
		- Forward-back is defined by the direction of the character, so no changes (1v1 has specific code to handle it itself)
- **Open Questions & Points to Extend**
	- How to handle training mode effectively ? Will probably need some system with the modules, but overall it can be covered.
	- How to handle AI ? Input injection is nice combined with the AI phase, but it's not the most intuitive method. Will need to redesign for better UX.
	- Rebinding interface is managed through editor and menu system.
	- Should we get different input maps for different players ? Maybe later
	- Is there a need to allow attacks to register themselves for better UX ? This will be handled by the attack module anyway
