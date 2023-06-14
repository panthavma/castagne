---
title: Basic Concepts
order: 2000
todo: 54
---

# Basic Concepts

Castagne's main goal is to be a flexible engine for making various types of fighting games. It tries to impose as little restrictions as possible, while trying to help the user by reducing their workload through good tools.

In order to achieve this, Castagne is composed of three main parts:
- **Modules**, which extend the engine and allows it to do its job. By changing the modules, you can change the type of fighting game (traditional, 3D...) or the graphics (2D, 2.5D or 3D), or even add your own custom functions.
- **Fighter Scripts** (.casp files), which define the behavior of characters through individual **State Scripts**. This is where you set your attacks, movements, and reactions. A lot of behavior is already implemented for you through what are called the "base scripts", and you can build upon other scripts.
- The **Castagne Editor**, which allows you to manage both through a more intuitive interface. The editor gives you access to several tools, flow control, and is extensible.

These are the parts most users are going to interact with. Castagne does the link between the behavior you want, its modules, and the underlying Godot engine so that you may focus as much as possible on the game itself, while online or optimization are taken care of as much as possible behind the scenes.

To give you an intuition of Castagne's commitment to flexibility, very few assumptions are built into the engine, and all functionality is done through modules, meaning you can write another physics system and have it still work with Castagne. All the actual behavior is written in the fighter scripts, meaning that if you don't like how the movement works, or how rounds end, you can change it, and all of that is readable directly from the editor. This also means that, by design, Castagne is made to be able to handle different types of games beyond regular fighting games.

If you want to learn more about those subparts, you may want to read these parts once you're done with the tutorial:
- For modules, you may read the [Choosing Modules](../choosing-modules) page, or the [Modules Documentation](../../modules).
- For the fighter scripts, the full information is available in the [Castagne Script Specification](../../casp-spec).
- The editor also has its own category called [Castagne Editor](../../editor).
- The internal engine design is discussed in the [Advanced User Guide](../../advanced).

<!-- TODO Choosing modules -->

<!-- TODO Simple schema of the parts -->
