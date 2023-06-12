---
title: Language Specification
order: 300
todo: 70
---

# Language Specification

This guide covers how the Castagne Script language works (.casp files), and is a recommended read when starting out.

> The language is set to have an upgrade in v0.7, with the rewrite of the compiler.
>
> The current compiler (more like a parser) is already working overtime compared to the initial draft in v0.2, so you may find plenty of bugs and weird behavior if you try to find the edge cases.

Castagne at its core works by treating characters as *state machines*, where every state can represent an attack, a movement option, a hit state, or whatever else. To know what to do during each, it executes a **state script**, which is created in Castagne Script.

Example syntax:
```
# Comment
## State Comment. These are shown on the navigation panel.

AttackDamage(200)

F5-10:
	Hitbox(-500, 20000, 5000, 10000)
else
	Move(-100)
endif

```

## Overview

Castagne Script has two basic types of instructions:
- Functions, of the form `FunctionName(Param1, Param2)`. These affect the game state and are provided by the modules, and thus are described in their respective pages.
- Branches, of the form `[LETTER][CONDITION]:`, which control which parts are going to be executed or not (for instance have an hitbox only on frames 5 to 10). Branches can be followed up by a `else` which will execute if the condition is false instead, and must end with an `endif`.

It is possible to add comments by starting a line with `#`.

During a loop, Castagne goes through several phases, and each state script will be precompiled for each phase. The full list is available [in the Engine Core advanced documentation page](../../advanced/enginecore), but the most important for us are:

- The **Init Phase**: Executed once per newly created entity.
- The **Action Phase**: The main phase, where you set up movements and hitboxes.
- The **Reaction Phase**: Executed after the physics, this is where the characters can react to hits.

In most cases, as a user, all you need to think about is the *action phase*. The init phase is mostly contained in states starting by `Init-`, and the reaction phase is handled by the base skeleton.

Some state scripts are given special treatment by the engine, and may be recognized by their names:

- `Character` holds basic metadata for the character. All variables entered here will be available both for the state scripts in game and menus outside of the main loop.
- States beginning with `Variables-` hold variable declarations.
- States beginning with `Init-` are meant to be executed during the Init phase and set up a new entity.

Casp files can hold several entities. One of them is the `Main` entity and serves as a default one, while others are signaled by using the `NAME--` prefix.

It is not necessary for a state to be meant to be executed alone, and the language provides some tools to help flag them.

A file can include a `Skeleton` attribute in the `Character` script. This is a reference to another file that may be loaded beforehand. States from files loaded later can override those with the same name, allowing them to extend or replace behavior. By default, Castagne will load the [base skeleton](../../intermediate/base-skeleton), but this can be stopped by setting the value to `none`.

Castagne Script is meant to be worked on in concert with the Castagne Editor, and thus can feature a few QoL features to that effect. While possible to edit Castagne Script in a different text editor, it is recommended to use the one provided by the Castagne Editor (this behavior may be supported more in the future).

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
	- `PReaction:` will execute only in the Reaction phase, etc.
- `I`nput branches will check if an input is pressed.
	- `IA:` will check if A is held.
	- `IAPress:` will check if A is just pressed.
- `S`equential branches are not yet implemented.

## Variables

A variable declaration follows the syntax given here:

```
MUT NAME TYPE() = VALUE

# Example
var WalkSpeed int() = 500
internal _PositionX
```

- `MUT` is the mutability of the variable, and may be `var`, `def`, or `internal`. Variables marked `internal` don't include `TYPE` and `VALUE`
- `NAME` is the name of the variable. It should be unique from other variable names (except when overriding) and other internal variable names.
- `TYPE` is the type of the variable (number, string...). You may add additional hints between the parenthesis. (not used yet)
- `VALUE` is the default value of the variable when the character is created.

Mutability is a key part of the variable, and changes how it is used and treated by the engine.

- `var` (Variable) is for data that can change. This is meant for operations and more complex behaviors.
- `def` (Define) is for constant data. This is meant for parameters of the character (like walk speed, or max health).
- `internal` allows access to internal variables of the engine, provided by the modules. By convention, these start with `_`. This is meant for complex behavior that requires internal engine data, and modifying them might result in weird behavior.

Type is the other key part of the variable, and can be either one of:

- `int`: Numbers
- `str`: Strings of characters
- Other types are meant to be supported in the future (v0.7 most likely)

Variables can be declared in *variable declaration blocks*. These are defined by their name stating with `Variables-`, or just being `Variables` (referred to as the main variable block), in order to help with organization. Variables can't be declared in two different blocks.

Variables of mutability `def` have some specific behaviors:

- They can be declared inside a regular state script, in which they'll be only accessible there. If they have the same name as another define, they'll override it for this specific state.
- These overrides also apply to `Call` and `CallParent` calls. As an example, state A has define `d = 5`, state B has define `d = 10`, and state B calls state A. If state A is executed, d will be equal to 5 for its code, but when called from inside B, d will be equal to 10. This can allow smart reuse of code.
- Defines can be edited graphically through the [*Custom Editors*](../../editor/editor-tools).

Variables can be set using the `Set` family of functions of the [Core module](../../modules/core).

## Skeleton

Each state may hold a reference to another file, called the skeleton. This allows a character to start from a common base to other characters, and as such reduce development time. This is also very useful for system mechanics

The `Skeleton` is set in the `Character` block and can be either of those values:

- A number: This will refer to a specified skeleton file in the config menu.
- A file path (starting with `res://`): This will load the specific file as a skeleton
- `base`: This will load the [base skeleton](../../intermediate/base-skeleton)
- `none`: This won't load any skeleton.
- Nothing (Default): This will try to load skeleton 0, and failing that will load the base skeleton.

The compiler will load every file in memory, and start compiling in reverse order, starting by the last skeleton and finishing with the main file. Files compiled later may override parts of the earlier ones as follows:

- Variables: The variable will take the value of the later file.
- States: The previous state will be renamed `Parent:StateName` (which may also push other overridden states further back), and the new one will take its place.

The skeletons may be set inside the config menu, and the [base skeleton](../../intermediate/base-skeleton) has its own documentation page for its features.

## Entities

A .casp file may hold several entities at once, which is useful for projectiles for instance.

Every file has a `Main` entity, which is the considered the default one in situations where no sub-entity is specified. Every entity may have its own variables and states, which are going to be used by the compiler when working it out.

Marking to which entity a specific state script belongs to is done through its name. With `ENAME` as the name of the entity, the convention is as follows:

- Regular State: Begins with `ENAME--`
- Init Script: `Init--ENAME`
- Variable declaration: `Variables--ENAME`

This is made easier through the entity templates in the editor.

To create a new entity, one must use `CreateEntity(ENAME)` from the [Core module](../../modules/core), which will automatically look for these states.

## Helpers and Warnings

Castagne Script in practice can be full of "gotchas", small insidious mistakes that can be easy to make and hard to spot (for instance, forgetting to call the code that handles being hit). Therefore, in order to make this easier, the editor has a few quality of life features which have some support in the language.

A lot of this support is done through the [Editor module](../../modules/editor), which provides functions that are not executed but serve to flag properties for the editor. These start with `_` by convention and may be ignored for code comprehension.

- **Base States / Helpers**: To make sure every state executes all planned behavior, a warning appears when they don't have a `Call` function towards a state marked as a *Base State* (done through the `_BaseState()` function). Alternatively, a state may be marked as a *Helper* if it is meant to be closer to a "function call", through the `_Helper()` function.
- **Categories**: To find states more easily, they may be assigned a category through the `_Category()` function. These can be nested using `/` between levels.
- **State / Entity Templates**: In order to make creation easier, states and entities may be started from a template. These are defined by name, with `TNAME` as the template name
	- State Template: `StateTemplate-TNAME`
	- Entity Template: `EntityTemplate-TNAME-Init` for the init script, `EntityTemplate-TNAME-Variables` for the variable declaration, and `EntityTemplate-TNAME-Action` for the default state the entity will use after initialization. Not all of them need to be filled out.
- **State Flags**: States can declare "flags", which may be then filtered in the editor. These can be declared either through `_StateFlag()`, or may be added automatically based on the code itself. They can be inherited through Base States.

More of these may be found in the [Editor Guide](../../editor) and the [Editor Module](../../modules/editor) documentation

## Advanced

Castagne Script is made to be able to be run in parallel, and as such can't access immediate parameters from other entities, nor set them immediately. Inter-entity communication functions are available in the [Core Module](../../modules/core).

It is meant to be compiled as bytecode, although this is not done at the moment. (v0.7 rewrite)

In the text file format, the states are separated by `:StateName:` lines.

Editing the files outside of the editor is possible, but not supported by the engine in a nice way. This may be improved in future versions but is not a priority.

The compiler does some optimizations, which are detailed in the [Castagne Compiler](../../advanced/castagnecompiler) page.
