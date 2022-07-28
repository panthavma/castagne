---
title: Language Specification
order: 300

template: docpage.hbt
pathtoroot: ../../
---

# Language Specification

This guide covers how the Castagne script language works, and is a recommended read when starting out.

Example syntax:
```
:StateName:

# Comment

Move(200)

F5-10:
	Attack(500, 20)
	Hitbox(-500, 20000, 5000, 10000)
else
	Move(-100)
endif

```

## Overview

Castagne has two basic types of instructions:
- Functions, of the form `FunctionName(Param1, Param2)`. These affect the game state and are provided by the modules, and thus are described in their respective pages.
- Branches, of the form `[LETTER][CONDITION]:`, which control which parts are going to be executed or not (for instance have an hitbox only on frames 5 to 10). Branches can be followed up by a `else` which will execute if the condition is false instead, and must end with an `endif`.

It is possible to add comments by starting a line with `#`.

Something that is important to understand, is that Castagne works through several phases each frame. The same script is going to be executed at each frame and each phase, but not all functions are executed for each phase. They are as follows:
- Init phase: Called once per newly created entity.
- Action phase: The main one, that will setup most actions such as movement or hitboxes. Most functions run there.
- Physics phase: Manages collisions and the resulting info. This one doesn't execute any scripts and is purely done through module callbacks.
- Transition phase: The phase where state transitions and reacting to hits is done.
- Freeze phase: Special phase that only executes when the game is in Freeze frames, instead of the usual ones. No functions run by default there and as such a P branch is needed.

Two special state scripts exist:
- Character holds basic metadata for the character. All variables entered here will be available both for the state scripts in game and menus outside of the main loop.
- Variables holds variable declarations.

One important attribute in the Character block is the `Skeleton`, which references another file to load beforehand. States later down the line can override the previous ones.
If no skeleton is specified, Castagne will load the one specified in the configuration. If you want no skeleton, set it to `none`.
The main value of this functionality is loading system mechanics in a special file.

## Branch Types

The branch types are as follows:
- `F`rame branches allows the script to execute only on certain frames.
	- `F20:` will only execute on frame 20, the first frame starting to count at 1.
	- `F10-20:` will only execute on frames 10 to 20, both included.
	- `F10+:` will execute on frames 10 (included) and up.
- `V`ariable branches check the value of a variable through a condition.
	- `VVariableName:` will execute when VariableName >= 1
	- `VVariableName==5` will only execute when VariableName is equal to 5
	- `VVariableName>=2` will execute when VariableName is superior or equal to 2
	- `VVariableName<2` will execute when VariableName is strictly inferior to 2
- F`L`ag branches check if a flag has been raised by a module or through the Flag function before continuing.
- `P`hase branches will execute only during a specific phase. When in the true part of the branch, all functions will execute forcibly.
	- `PFreeze:` will execute only in the Freeze phase.
- `I`nput branches will check if an input is pressed.
	- `IA:` will check if A is held.
	- `IAPress:` will check if A is just pressed.
- `S`equential branches are not yet implemented.

## Advanced: Compilation

Each file stores several state scripts, separated through `:StateName:` lines.
Compilation happens when launching the Castagne engine.

The parser is pretty simple itself, but does some optimizations:
- `Call` functions are inlined whenever possible.
- Scripts are precomputed for each phase and each state.
