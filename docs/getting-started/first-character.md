---
title: Your First Character
order: 4000

template: docpage.hbt
pathtoroot: ../../../
---

# Your first character

Let's get to the meat of things, by making our first character together. We are going to build a simple version of the *Castagneur*, one of Castagne's official characters. This is separated in two parts: this one where we see how to get started, and the next where we will complete his moveset.

## Initial Graphical Setup
Usually, we want to start with a 3D model or sprite sheet. Thankfully here, Castagneur is already set up, and you can use him as a base for prototyping or your own projects.

This tutorial will suppose you are using Castagneur. If you want to use your own character for this, you will need to either:
- For 3D characters: export your character to Godot (most likely through a `.dae` or `.gltf` file) in your project, create an inherited scene from it, set up your materials as you want, and then save it to the disk.
- For 2D characters: export your spritesheet to the Godot project.

For more information on that and on available models and animations, please consult either the Intermediate Guide's [Graphics and Sound Setup](../../intermediate/graphics-sound) section, or the [Castagne Characters](../../characters) category.

## New Character

Our first step is going to be opening the editor and clicking new character. Put the file somewhere sensible, like `fighters/MyFirstCharacter.casp`.

<!-- TODO Screenshot -->
This should have opened up the editor along with your character. Let's take a quick tour:
1. The main game window. You can playtest your game here.
2. The code window. This is where you edit your scripts.
3. The reload button, which allows you to load your changes in the game.
4. The state scripts button. You can change the currently edited state through here.
5. The file button. You may change your current file among those loaded through here.
6. The tool window. It can display various tools, but by default it will show you your compilation errors.
7. The flow control buttons. You can restart the situations or control the speed of the game through here.
8. The documentation window. From here you may access this documentation, or get a quick reference of the current function.

By default you will only have two state scripts: `Character` and `Variables`. Those are special as they don't represent actual states, but general data about your character and attributes to track.

> From now on we will see some code written in Castagne Script (.casp). This language is made to be as simple as possible for the user (by automating a lot of the work and boilerplate code under the hood) and extensible, and is what allows Castagne's flexibility.
> Concepts will be explained as we go on through comments (lines starting with `#`), and you may find the [full reference here]() for more information.

Let's start by doing a few things to have our setup complete. Let's start from the `Character` block, to write the data we are going to need outside of the fights.

```
# Let's start by writing in the name of the character.
Name: Castagneur Jr.
```

> This is a bit empty right now as this block helps contain metadata about the character, which is going to be mostly used from Castagne 0.6 onwards.

<!-- TODO Complete once we got Castagne 0.6 -->
Then, lets continue by writing in the `Variables` block, in order to set up our character proper. Because the Castagneur is the base character, it will show up even if you don't do it, but you probably want to learn how to add characters down the line.

```
# ------ If using models (our case)

# This allows the engine to know what model to load by writing in the Godot path containing it. (Should be a valid model to display)
MODEL_PATH: res://castagne/example/fighter/CastagneurModel.tscn

# This allows the engine to know where the model's AnimationPlayer node is. In most cases you can leave as default. Default: AnimationPlayer
ANIMPLAYER_PATH: AnimationPlayer

# This controls the scale of the model in permil (1000 = 1.0). Default: 1000
MODEL_SCALE: 1000
```

Here's what you do if you use Sprites instead :

```
# ------ If using sprites

# This enables the switch that sets up sprites instead of models
USE_SPRITES: 1

# This should be the path to your spritesheet. At the moment, it is considered your spritesheet is regular.
SPRITESHEET_PATH: res://castagne/example/fighter/sprites/StickmanSpriteSheet.png

# Here you can set the amount of sprites horizontally and vertically respectively
SPRITESHEET_NB_X: 1
SPRITESHEET_NB_Y: 1

# Here you can adjust the size of a pixel in the 3D world.
SPRITESHEET_PIXELSIZE: 100

# Here you may set where is the anchor point of the sprite (in most cases, between the feet)
SPRITE_ORIGIN_X: 0
SPRITE_ORIGIN_Y: 0
```
> The values we set here are not only derived from modules, but also from the other .casp files. This model setup in particular is made through the Base.casp file, if you want to investigate further. Please see the relevant documentation page for more info. [TODO]

Press the reload button to see your changes. The model should appear in the game!

<!-- TODO Change the spritesheet once we have a default 2D Character -->

> Variables might be easier to set in a future version
<!-- TODO Complete when that's done -->

## Tuning the variables

Next up, we're gonna tune the character itself. Let's start by adding in some animations, and then we will adjust the physics.

For the animations, we're going to use a special system from `Base.casp` to make it happen for us quickly. You may overwrite the actual state scripts for your needs later on.

```
# This switch will tell the file to actually use these standard animations
USE_STANDARD_ANIMS: 1

# These are the names of the animations. There's a lot predefined, so I haven't copied them all.
# These are already set to Castagneur's animation names, so don't feel pressured to copy them.
ANIM_STAND: Stand
ANIM_CROUCH: Crouch
ANIM_JUMPSQUAT: Jumpsquat
ANIM_LANDING: Landing
# [...]

# Walking animations are a bit special because they have looping built-in. Please copy this to make them work.
ANIM_WALKF: WalkF
ANIM_WALKF_LOOP:70
ANIM_WALKB: WalkB
ANIM_WALKB_LOOP:70
```

> There is no sprite equivalent at the moment, but you may override the associated state scripts (AnimWalkF, AnimLanding...) to get the same results.

Press reload to see the character now animate while moving. Neat!


Now it's the time to actually change our character a bit. You may tune the variables as you see fit, but here's something to get started.
```
# Here we can affect walk speed. In this example, we move a lot faster forward than backward.
WalkFSpeed: 1300
WalkBSpeed: -850


# Here are the parameters for the jumps.
JumpsquatFrames: 4
JumpFForce: 1200
JumpBForce: -1000
JumpNForce: 3500

# Parameters for the air. Gravity affects how fast you come down, while LandingLag and DefaultAttackLandingLag will help you manage those more easily.
Gravity:-200
LandingLag: 4
DefaultAttackLandingLag: 7
```

> This is only a sample of the tunable variables. Please see the relevant documentation pages for more info. [TODO]

Press reload as needed while tuning these. You should be able to feel the difference in handling!


<!-- TODO Sounds when we have sound -->
<!-- TODO Redo once it's easier (variable writer) -->

## Our first move: Straight Jab

Finally! Let's write our first attack here, a simple standing jab. While you may name your attack however you want, in practice it's easier to name your attack using [numpad notation](), as it will get picked up automatically by `Base.casp`. Here let's name it `5A`.

```
# This is a function, which allows us to actually affect the state of the game.
# They take the form `NameOfFunction(Parameter1, Parameter2, ...)` ; where NameOfFunction is the exact name of a function, and Parameters are the associated values.
# The complete list is available in the documentation for the modules, and a small description of a function is available at the bottom when recognized.
# The Call function will execute another state script of a given name present in the file stack, here we use a helper script from Base.casp to set our attack up.
Call(StandingAttack)

# The Hurtbox function allows us to be able to be hit. When an hurtbox and an opponent's hitbox intersect, the attack happens.
Hurtbox(-5000, 5000, 0, 20000)

# This is a branch, which allows us to execute parts of our code only sometimes.
# They are of the format `[Letter][Condition]:`, where [Letter] is the type of the branch, and [Condition] helps specify exactly when to take the branch.
# This one is a Frame branch, which will only execute parts when we are at the specified frames (here, from frames 6 to 8 included).
F6-8:
	# The attack function will declare an attack. The first number is the damage, and the second the total amount of frames.
	Attack(1000, 35)

	# Once we have started writing our attack, we can customize it through functions. Here we will set the hitstun high enough to have the attack link into itself.
	AttackHitstun(45)

	# Finally, once the setup is done, actually put the attack out through its hitbox.
	Hitbox(0, 12000, 12000, 16000)

# A branch must come with an endif to tell the engine where it ends.
endif

# Play the corresponding animation, so we can see the attack!
Anim(5A)

# Finally, let's add canceling from this attack into others. This will be useful when we will have a second attack.
Call(AttackAddAllNormalsCancels)
```

Whew, that was a lot of words to describe a few functions. You will become more familiar with it as you use the software.

You may now press the reload button to see your attack by pressing whatever you bound to `A` (by default, numpad 4 or H on keyboard, and X/Square on pad). Try to link it into itself for a simple combo!

<!-- TODO Update code when tutorial is done -->
<!-- TODO Come back when we got sequential branching -->
<!-- TODO Numpad notation page -->
<!-- TODO Update once it's easier (templates) -->

## Second move: Crouching Sweep

Lets make another move in the series, this time a crouching sweep, `2B`. With this attack we will explore a bit more ways to customize an attack in order to do a cool [low]() [launcher]()! We will also extend the [hurtbox]() during the attack, in order to make it [whiff punishable]().
<!-- TODO Lexicon -->

```
# We will use CrouchingAttack instead of StandingAttack this time.
Call(CrouchingAttack)
Call(AttackAddAllNormalsCancels)

Anim(2B)

F8-10:
	Attack(1200, 47)
	AttackHitstun(42)

	# Let's make the attack slightly negative on block, so your turn ends if you don't cancel into another move.
	# This is equivalent to setting blockstun manually, but will adapt with your move's length.
	AttackFrameAdvantageBlock(-4)

	# Flags can allow us to give more information to an attack, which will get passed on to the opponent on hit or block. Here, the `Low` flag makes the attack unblockable with standing guard. This flag is defined by the Attack module.
	AttackFlag(Low)

	# As a bonus, let's add the `AnimTrip` flag to play a tripping animation, because it will look cooler here. This flag is defined by Base.casp.
	AttackFlag(AnimTrip)

	# Let's make the attack launch, which means it will propel the opponent upwards.
	# The AttackMomentum family of attacks allows us to do that, by specifying how the opponent will move.
	AttackMomentumHit(1600, 1200)

	# However! On grounded block we don't want to launch upwards. AttackMomentum can take two vectors, one for the ground and one for the air, so we'll use that.
	AttackMomentumBlock(1600, 0, 1600, 1200)

	Hitbox(0, 15000, 0, 7000)
endif

# To extend the hurtbox, we need to know when to do so. First we will add an hurtbox that will stay always
Hurtbox(-5000, 5000, 0, 15000)

# Then we add a lingering hitbox a bit after the hitbox is out. Subtle changes here can drastically change how a game is played!
# F9+ tells the engine to branch here from frame 9 onwards.
F9+:
	Hurtbox(0, 14000, 1000, 8000)
endif
```

You may now reload and press down and `B` (keyboard J or numpad 5, or Y/Triangle on pad)to see the move in action! You can cancel the sweep into the jab and vice versa now too, try it out!

<!-- TODO Update code once tutorial is done -->
<!-- TODO Update once it's easier (templates) -->

## Third move: Jumping Bat Swing

Let add one last move to the mix, a downwards bat swing done from a jump! This one is going to be called `j5C`. It is a simple attack, although we will add a few things to make it interesting: a more accurate hitbox, and manage the landing lag.

```
# We use AirborneAttack here as it will manage all the landing logic.
Call(AirborneAttack)
Call(AttackAddAllNormalsCancels)

Anim(j5C)

F9-12:
	Attack(1200, 50)
	AttackHitstun(50)
	AttackBlockstun(12)

	# Lets add a bit of landing lag in order to convey that this is a riskier move. This is defined by Base.casp
	Set(AttackLandingLag, 14)

	# This hitbox doesn't cover everything cleanly, we need a second one.
	Hitbox(0, 14000, 3000, 12000)

	# Since the attack is already set, each subsequent hitbox will have the same properties. We can use this to set a few hitboxes easily.
	Hitbox(0, 9000, -6000, 14000)
endif
```

<!-- TODO Update once it's easier (templates) -->
