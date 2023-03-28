---
title: Castagne Philosophy
order: 500
---

In order to provide a coherent tool, Castagne follows a development and design philosophy that follows **a few core ideas, against which all decisions must go through**. These are what I (Panthavma) defined as most important for my own requirements and ideals, and then refined as time goes on, so this article will be more subjective. As such, it is useful to remind people of my skillset and situation: strong programming skillset especially code architecture and graphics programming, specialized 3D skills, and working on projects on the side as a solo dev with not a lot of time to dedicate. As such, I needed a tool that can handle all the funny ideas I could throw at it while allowing me to be as fast as possible when making games. Also while I want to do what is mainly a fighting game, I want to be able to reuse this over various projects, as to not waste that development time. These are the core pillars, in rough order of importance.

## Aggressive Focus on Efficient Usage

This is one of the main drivers of the tool, to be able to work very quickly. Time can be sparse, and I don't want to spend it doing busywork. Being solo also limits the opportunities to play with others, and as such I need tools to help me design each iteration better. This results in a few ideas:

- **Short iteration time**: Games get better with iteration, and as such each iteration should be as fast as possible. This compounds with the fundamental transformation of usage when an iteration becomes fast enough to be spontaneous, which allows finding new directions that wouldn't have happened if iterations were more deliberate. This is reflected with the editor being in play mode always, and the design of the Castagne Script language and base files to need as little lines as possible.
- **Reduce bug probability**: Smart design that protects the user allows them to be more careless, and thus faster. It also reduces the time spent debugging instead of making the game. This is mostly seen through the Castagne Script language, which was created at first to avoid boilerplate and manual memory management (two insidious sources of bugs and refactorings), and the Editor's code quality warnings.
- **Data rich environment**: To make good choices, one needs to understand what is going on. As such, I want to have the data I need on hand at all times, with as little manual work as possible. This is seen through tools like the combo unit tests and training mode options.
- **Focus on core content**: Games are big, and some parts take a lot of time to get right, and are needed for final quality, but aren't part of the core experience. The engine needs to be able to do as much as possible of that work, so that I can focus on my game specific parts. This is seen through the inherent rollback-readiness of Castagne Scripts and the menus systems with their ability to add options automatically.


## Flexibility and Extensibility

This is the second main driver, as to justify the development time of the tool it needs to be reused. This compounds with my desire to include wilder ideas and not be limited by the engine.

- **Factorization of work**: A lot of parts are common to a various fighting game types and fighting game adjacent types, and it would be unwise to lock the tools to only one. As such the engine must be able to handle very varied game types with little to no code to rewrite. This is the main origin of the modules.
- **Integration in Multiple Contexts**: In order for the engine to handle use cases in fighting-focused games, other games with a fighting component, and pipelines, the engine's flow must be as clear cut as possible, with as little global setup as possible. This is why the engine can be instanced in a flexible way.
- **Replaceable Parts through Clear Intefaces**: Some useful choices might lock the engine for some games, or the tools might be unsuited for specific parts. As such, most parts of Castagne should be replaceable without breaking the engine (too much). This is seen through modules once again, and the menu systems.


## Power-User Driven, Learning and Assisting over Simplifying

One big concern I have is to have as few limits as possible on the tool itself, even if approachability takes a hit. This means the tool will focus on its most hardcore users, and would rather teach instead of restricting the tool.

- **Potential First**: Tools are designed first and foremost on maxing out their potential. User friendliness may be achieved later or worked around, but fundamental limits are a lot harder to remove. This is reflected in various places with lots of options, like Base Casp files.
- **Leveling-up Users**: If the tool is made with power users in mind, it must provide a way to get there, both explicitly and over time. This is reflected in external resources like this documentation, and user interfaces that tries to teach the user.
- **Initial Momentum**: Tools like this can become very complex and intimidating, and in these cases initial impressions can give the will needed to power through. This is achieved through features like the first time flow tutorial, and the various default editors, prototyping kit, and official Castagne projects.

## Real Game Development Features

Each line of code is an additional cost to write and maintain, and as such features must be actually useful for games instead of decoration.

- **Real Use Cases**: A tool must show interesting potential impact on game or game production before being implemented. This means tools are developed in answer to a problem, instead of finding problems to apply the tool to.
- **Pre-Stress-Tested Designs**: In order to ensure the tool can function is various situations, each part must be evaluated against potential varied use cases. I do this by keeping a list of a at least dozen games, existing, in (potential) development, or fictional, to compare the tool against and eliminate as many blindspots as possible before implementation.
- **Game-Driven Development**: The best way to shape the tool correctly is to confront it to real game development, and as such trying to attach features to pilot projects. This was done for example with Kronian Titans' and Molden Winds' developments.

## Bridge Between Hobby and Professional

Just like me, this tool must handle both the recreational use case, but also scale with the user when they need to go beyond just fun. This is also a way to ensure the ecosystem around the software is strong.

- **Fun to Use**: Making games should be a pleasure, and as such it must allow people to express their creativity as seamlessly as possible. This is reflected in many of the other pillars, as well as the lighthearted language and "lore" around the engine's mascots.
- **Clear Path to Mastery**: Just like in fighting games, mastering a system is fun and rewarding. This should have clear ways to do so instead of relying on obscure knowledge, and be encouraged naturally as part of engine usage.
- **Multiple Entry Points**: Game development is intimidating, and as such there should be many ways to get started. This is reflected by the default custom editors, the prototyping kit, and the design of the official Castagne projects themselves: to give a taste of game creation as accessibly as possible.
- **Adaptable to Varied Situations**: A lot of specific constraints may be imposed, especially on more professional projects where workarounds sometimes can't be used. The engine wants to manage this through its flexibility in usage and use of Godot.
- **Open to Collaboration**: Games are inherently team efforts (except when I do it but that's because I'm stubborn), and can be very fun to do with friends or colleagues. As such, there needs to be easy ways for folks to collaborate, both as part of a team on Castagne projects through features like Custom Editors, and as part of a wider Castagne community through for instance open-source game projects.
