---
title: Character Editor
order: 2000
todo: 53
---

# Character Editor

The Castagne character editor is separated into several parts:
- At the top left, the status bar, which can be used to save or go back.
- On the middle left, the game window, where you can play the game.
- On the bottom left, the tool panel, where information and controls lie.
- On the top right, the navigation panel, to change file or state.
- On the middle right, the code panel, where you program moves.
- On the bottom right, the documentation panel, where you can see the current function's documentation or open the window itself.

The character editor will save over your files often, and as such it is recommended to have source control on your project.

## Tool Panel

The tool panel is separated into 4 parts:
- On the left, restart control.
	- Execute move will reload the game and force the character to use the specified state at the specified frame. If no state is specified, the editor will use the one selected by the code window.
	- The other buttons change the starting state.
- At the top, flow control.
	- Run and Slow are two modes to run the game in full speed or one third speed. If none are active, the game doesn't run.
	- Next frame will stop the game and advance one frame.
- On the right, the reload and tool buttons.
	- Reload will save and apply the changes to the scripts.
	- Tool will open the tool chooser.
	- The arrow button will extend the tool panel to show more information for the tool.
- At the center, the tool window, that changes depending on the current tool.
	- The only one implemented at the moment is the compilation tool, that shows compilation messages and errors. Double click an error to be brought to it in the code window.

## Navigation Panel

The navigation panel has three buttons:
- Top row, first button, is the file button. It allows you to choose the file to edit. Some files may be locked by default, namely those coming from Castagne itself, and should stay that way for most users. It is also possible to lock the base skeleton file for larger projects.
- Top row, second button, shows the state scripts called by the current state script.
- Bottom row allows you to choose and manage state scripts.
	- The new state button opens up a template chooser. Templates can be overwritten or added by creating state scripts stating with `StateTemplate-`.
	- The delete state button will delete the current state after confirmation.
