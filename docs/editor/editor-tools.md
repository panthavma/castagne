---
title: Editor Tools
order: 3000
todo: 53
---

# Editor Tools

The Castagne Editor provides a few Editor Tools to help the creation of the characters. These are located at the bottom of the editor window.

Tools may be changed through the `Tool` button, and may be expanded with the `^^` button

## Existing Tools

### Compilation

This tool shows the various compilation errors. You may go to the associated file when possible by double clicking an element.

### Input

This tool can show the current state of input, and even overwrite it for various players.

The input viewer will display input for the current main entity of a player.

Input overwriting only works for direct and combination game inputs.

## Creating a tool

This part is very probably going to be rewritten somewhat for v0.59, so in the meantime you should look at the implementation of the other ones yourself. Some pointers:

- To add a tool, you'll need to also register it in Castagne Config.
