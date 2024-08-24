---
title: User Interface
order: 350
todo: 54
lastver: 54
---


# User Interface

Castagne's User Interface system allows you to display in-game information to the player, through bars, numbers, and other widgets. This system interfaces with Godot engine more than others as it relies more on its features, and as such some intermediate operations are meant to be done from Godot's editor proper.

The main concept of the system is ***Widgets***. A widget is an interface element displaying one or several values from the current state of the game. They can be added in two ways:
- From CASP, by filling in the UI Specblock.
- Manually, by adding the widget to the UI root scene.

## Widgets

Widgets are updated during the graphics update step. They can be added from CASP, which will try to add them at a hook point defined in the root. You are able to specify the variables and assets to use, but their actual use is defined by the widget itself.

The type of widget can be either "custom" to load any scene, or one of the other default types to load the default associated widget, which can be changed from the Castagne config.

### Default Widgets

Default widgets are meant as an easy way to add information during prototyping or for simple widgets. The

| Type | Description | Variables | Assets |
| --: | -- | -- | -- | -- |
| Bar | A fillable bar that can show two values | Main: Main value to show<br/>Sub: Shown behind the Main value<br/>Max: The full bar capacity needed for ratios | A1: Main bar texture<br/>A2: Sub bar texture<br/>A3: Background texture |
| Icons | Adds icons one after the other | Main: Number of icons | A1: Icon |
| Icon Switch | Shows one icon from a list | Main: Icon ID to show | A1: Icon for 0-<br/>A2: Icon for 1<br/>A3: Icon for 2+ |
| Text | Shows a simple label | Main: Text | / |

### Custom Widgets

You can use any scene as a widget as long as it implements the interface of `res://castagne/helpers/ui/CUIWidget.gd`.

The easiest way is reusing one of the widget scripts from the default section, in `res://castagne/helpers/ui/widgets`. Here are a few additional remarks on each:

- Bar: The widget code actually handles all the values given by godot, meaning you can do rotational filling bars and have them mirror properly.
- Icons: You can change the appearance of icons easily, by adding the nodes as children yourself beforehand. The code will only create new icons once at the end.
- IconSwitch: Again, any node can be used if added as children, so you can actually change the visibility of a lot of stuff
- Text: Straightforward

Save your scene and give the path to CASP to use it with the Custom type, and it should add it to the hook point you want.

### Creating new widgets

Sometimes, you need something complex. You can create new widget types by inheriting `res://castagne/helpers/ui/CUIWidget.gd`. There are helper functions to validate data and gather them.

If you create a new widget, you'll also need to handle mirroring properly through the `isMirrored` value.

## Roots

Before adding widgets to the UI, it needs to create the hooking points. It does this by spawning it the UI Root. There are two:

- Global root: Added at the start, holds general widgets and the root for the player ui roots.
- Player root: Added with as many players as needed, can be mirrored. Can be changed per player in the BID.

You can visualize the current hook points by using the "Visualize UI" Debug switch from the debug tool. Every node can be a hook point.

Widgets already present in the global or player root are detected and updates automatically.
