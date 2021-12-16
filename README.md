# Castagne
Castagne allows you to make fighting games more easily. It is a layer built upon Godot that manages the internal logic needed, so that you can focus on making the game itself.

# Current Status
The project is currently still unstable, and will be until I implement rollback netcode, as it might cause some internal architecture shifts. Castagne is however still usable to start making a local multiplayer fighting game, albeit with some of the more graphical aspects missing.

Most of the development of Castagne will follow the development of Kronian Titans itself.

# Setup
- Copy the whole folder into your godot folder
- Copy project.godot to the root of your project (or use its adjustments)
- Add .casp files to your build

# Example Project
A set up example project can be found here : [https://github.com/panthavma/castagne-empty-project]

# Projects Using Castagne
- [Kronian Titans](https://oddgeargames.itch.io/kronian-titans)


# Roadmap

## Currently worked on

- [X] Usable version
- [ ] Implement Rollback netcode
- [ ] Add support for multiple entities
- [ ] Add sound-related functions
- [ ] Add replays
- [ ] Add documentation and an example project
- [ ] Add a way to extend menus seamlessly

## Future

- [ ] Create an editor for more graphical editing
- [ ] Investigate how to extract and use data from games / replays to help devs and players
- [ ] Support more gameplay types (3D) and more graphical types (2D, 3D)
- [ ] Tests
