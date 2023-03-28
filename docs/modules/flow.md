---
title: Flow
order: 500
todo: 53
---

# Flow Module

This module handles initial setup and exit conditions.

## Design Proposal (for v0.53)

### Initial Research
- Concept
	- The module needs to handle entry into the match
	- The module needs to handle when to stop the match (victory condition)
	- The module needs to handle how to exit the match
	- The module also handles part of the players
	- Not necessary to cover all types of flow (user can make a custom module), but common cases need to be supported
	- Links: Input module (player management), Menus (prepare matches)
- Use Cases
	- Fighting Game
		- Most common use case, needs to be properly supported
		- Victory through death or timer
		- Rounds or not (round reset, continue, or single round)
		- Multiple characters, multiple players (like 3v3), can be asymmetrical
	- Alternative Modes
		- Training: Needs to be able to change parameters on the fly and reset
		- Combo Trial: New victory condition
		- Tutorial: Needs text
		- Story: Needs triggers
		- Maps: Needs some way to control potential hazards or objects
	- Brawler / Linear Level
		- Mostly Beam them alls and Character Actions
		- Need to spawn opponents during fights
		- Lock player to a screen for a time
	- Open Level
		- For semi-open platformers for instance
		- Different spawn points needed
		- Need to remember some data like collected objects

### Technical Proposition

- **Overview**
	- Engine is initialized with *"Battle Init Data" (BID)*
	- Flow module reads the data and creates players and entities needed
	- Module handles some of the events during the match (round end) to keep it flowing
	- Module detects final event, generates *"Battle End Data" (BED)*, and makes a callback to an external part
- **Init Flow**
	1. Global Init
		- Initializes the global parameters from the BID.
		- Adds players to the Player Init queue.
		- Loads map and music
	2. Player Init
		- Instanciates player with base player data
		- Defers to the input module to create the correct input method
		- Overrides parameters using the BID
		- Adds entities to the Entity Init queue.
	3. Entity Init
		- Loads the correct Castagne scripts.
		- Instantiates entities with base entity data specified by the script.
		- Overrides parameters using the BID
- **Mid-match management**
	- *Triggers* system: a condition is checked every frame and when accomplished, an action / callback happens
		- Simple observer pattern. Godot signals might be unsuitable somewhat because we don't know which ones exist in advance
		- Stored in the global memory stack
		- Examples: Round end when one player is at zero health, door opens when all opponents are defeated, cutscene starts when a point is reached
	- Activation types
		- Watch: Wait for a variable to get to a specific value (or similar condition)
			- Most common, can be very generic too
		- Event: Happens on a callback
			- Can't be from any external source if we want to keep rollback
			- More investigation needed to determine the specifics, but can be left for a later date for now
		- Script: A script may be executed to check if an event happens and return a value
			- Can be a GDScript, but maybe even a Castagne Script ?
			- More advanced, can be left for a later date too
	- Action / Callback types
		- Global Flag: Raises a flag on all entities
			- Current way it works, is effective
		- Alter Value: Changes the value in one or more entities.
			- How to select a specific entity? It may not exist anymore
		- External Callback: Call a function
			- Can be used with Godot signals? It's pretty much equivalent, but something that could be investigated later
		- Castagne Script: Execute a specific Castagne Script
			- How to target it again? Some sort of global script?
			- Might need to extend Castagne script
	- Interfaces
		- GDScript: Function interface
			- Should work with a state handle as usual
		- BID: Init basic triggers in advance
			- Simplest method, but static
		- Castagne Script: Add triggers from within functions
			- Might need to be more limited, same constraints of targeting and castagne script extensions
			- Can be left for later
- **Exit Condition and Protocol**
	- Can be handled as a special trigger I think.
	- Exit types:
		- Regular/Battle End: Regular exit at the end of a match
		- Abort/Return to menu: Happens when a player exits through a menu
		- Disconnect / Error: Should that be handled here? Maybe through an online module?
	- Exit Data
		- Creation of exit data done by one or more GDScript functions.
		- Format may be left open, and advanced users can thus extract exactly what they want through a stateHandle
		- Could be interesting to let Castagne scripts also mark data for exit?
		- Contains some regular values, like `winner` and `exittype`.
	- On exit, callback happens
		- Callback can be set from BID. Function takes a stateHandle, BED (which also contains the exit type), and reference to the module.
			- Most likely change is just checking if the exit type is regular, if so do some specific behavior, otherwise execute the standard exit function.
		- If callback is null, executes the standard exit function
			- On regular exit, will show the battle end screen
			- On abort type exit, will return to the correct menu
			- On disconnect, will defer to an online module
- **Data Format of BID (Battle Init Data)**
	- Specifications
		- Data is not symmetrical between players / entities: one player may spawn 5 entities against 3 players with one each for instance
		- The nested structure of players and entities works from a common base: these dictionaries will be
	- Root: Dictionary
		- `players`: array containing player data (see below). Contains n+1 players, ID 0 is a common base for all
		- `overrides`: Values from the global memory stack to be overridden (dict). Examples: number of rounds
		- `entities`: Additional entities not owned by any player. Contains n+1 entities, ID 0 is a common base for all.
			- Might require castagne script scope extension. Can be handled at a later date.
		- `map`, `music`: Temporary global parameters
		- `exitcallback`: Function pointer to call when exiting the match
		- `triggers`: Initial triggers to be set at the start
	- Player Data: Dictionary
		- `entities`: array containing entity data (see below, once again). Contains n+1 entities, ID 0 is a common base for all
		- `overrides`: Values from the player memory stack to be overridden (dict). Examples: input preferences
		- `input`: Temporary value for the input method (to be revisited later)
	- Entity Data: Dictionary
		- `scriptpath`: The path to the Castagne script file used for the character (string or ID?)
		- `overrides`: Values from the entity memory stack to be overridden (dict). Examples: position, color palette
	- Example for Molten Winds (1v1, 3 characters each)
		- `players` array has three entries: base, player1, and player2. Each player has its own set input method
		- For each player, `entities` has 4 entries: base, point, mid, anchor. The last three refer to the correct script.
		- Player 1 has an override on his base entity: `_PositionX = -20000`. Player 2 has a similar one: `_PositionX = 20000`.
		- `map` and `music` refer to the ones selected by the players during character select.
- **Maps and Alternative Flows**
	- Map is loaded in the first phase and is a simple scene
		- This could be extended by using scripts, but this might require an extension of Castagne script scope
		- Map Hazards / Objects / Interactibles should be added as entities
		- Should be easy to manipulate with Godot's editor, and thus use the "entity injection" flow
		- Can be left for a later date
	- Entity Injection flow: Instead of relying purely on the flow module, allow entities to spawn / register themselves
	 	- How does that work with rollback? Could be limited to single player games, but a bit meh
			- Probably alright as long as its deterministic
		- How do entities register themselves? Maybe just use "spawners" (objects that will ask for an entity to register) ?
		- Use case: linear levels, spawning enemies and obstacles placed from the Godot editor
		- If using godot physics modules (ie light Castagne integration instead of full), this might not be needed.
		- Can be left for a later date, entity adding flow is robust enough to not care about where they come from, but might be better to keep the loading logic
- **Module Config and Interface**
	- Mostly about BID setup, code interface can send whatever BID for flexibility
	- Should be able to get a base BID config to change, for simplicity.
		- Base BID defined by the modules: will need to add some function to the CastagneModule sandbox
	- To keep flexibility at max, create inherited flow module FlowFighting for fighters. It will initialize the parameters in a simpler way.
		- Config parameters added and transferred into the BID for easier use:
			- Distance between characters at round start
			- Amount of players, characters per players
			- Number of rounds
		- BID will contain players, entities, overrides, and triggers to have stuff work as expected.
		- Handle game modes through an additional parameter? Config parameter, in the BID, or both?
	- Editor needs some way to manage the way more flexible flow.
		- Castagne starter might also need it, but it can probably benefit more from a rework rather than be included here, as its functions are being taken over more and more by the editor.
		- Probably worth to create an interface through a function, and then display it
			- Can have a standard one based on the values present in the base BID
			- Can save previously configured BIDs for easy access. Config / Local config can remember up to N most recent flows, and can pin some of them to not have them be deleted.
				- Local config by default, but needs to be able to add some to the regular config to be teamwide options.
		- Sounds very hard for newcomers however. Should also get a window where you can just select a character, a map, and go.
			- This is not applicable for all flows however.
			- Can be implemented through the custom function in the FlowFighting module, for best of both worlds.
- **Common scenarios and solutions**
	- Simple fighting game
		- Should we make a FlowFighting module with a simpler interface?
		- Round transition is handled through the base casp
	- Alternative game modes
		- If simple: change parameters from BattleInitData
		- If complex: Change castagne config using additive config files
	- Linear Level
		- Obstactles may be placed in the Godot editor, and register to the engine using an alternate flow.
		- BED will feed BID data from one part to the next, for values like HP or ammo.
- **Open Questions & Points to Extend**
	- Should Castagne Script be extended to work beyond just characters ?
		- What would that look like? Collection of "script functions"?
		- What would it be attached to? General flow? Maps? Cutscene direction?
		- Is the additional complexity useful vs writing custom modules?
			- Could be useful to setup additional things, but can't BID already do it?
		- How would we edit those?
		- This can be left for later, and reevaluated for v0.56 (where it might be useful) and v0.7 (where castagne script is more or less finalized)
	- What should this dev pass include?
		- All the base framework for this, including BID, Triggers, and BED
		- Round / Game Mode management may be left for v0.54, as it will be in a better place to experiment
		- Map and alternative flows stuff can be left for v0.56, as it won't affect most regular 2D fighters

### Discussions

- Test drive, hop on Discord to talk about it. Main revisions will appear here.
- 2023-01-15: Initial proposal by Panthavma
