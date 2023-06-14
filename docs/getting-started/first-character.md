---
title: Your First Character
order: 4000
todo: 53
---

# Your first character

Let's get to the meat of things, by making our first character together. We are going to build a simple version of **Baston Labatte**, one of the *Castagneurs* (Castagne's official characters). This tutorial is organized in two parts: this one where we see how to get started, and the next where we will complete his moveset.

## Initial Graphical Setup

Usually, we want to start with a 3D model or sprite sheet. Thankfully here, Baston is already bundled with the engine, and you can use him as a base for prototyping or your own projects. He also has his setup done, so you can get to creating immediately.

This tutorial will assume you are using Baston as a base. If you want to use your own character for this, you will need to either:
- For 3D characters: export your character to Godot (most likely through a `.dae` or `.gltf` file) in your project, create an inherited scene from it, set up your materials as you want, and then save it to the disk.
- For 2D characters: export your spritesheet to the Godot project.

For more information on that and on available models and animations, please consult either the Intermediate Guide's [Graphics and Sound Setup](../../intermediate/graphics-sound) section, or the [Castagne Characters](../../characters) category.

<!-- TODO Graphics? Characters ? -->

## New Character

Let's start by creating the character file. Open the editor and click 'New Character', and create a file inside the godot project (but not the castagne folder itself) with a name ending in `.casp`. I can propose `fighters/BastonJr.casp`.

> If choosing an existing casp file, it will be added to the list safely (even if the window currently says it will overwrite).

This will then prompt you to choose a base *Castagneur*. Castagne's example characters are made to be tweakable and with plenty of animations, as you'll be able to see later. Using one as a base will take care of the setup of the graphics and animations for you, so that's what we will be doing here. Select `Baston Labatte`.

You'll then be taken to the Characters Setup menu. We will see it another time, for now just click 'Confirm' at the bottom.

<!-- TODO Check si on retourne pas au menu principal -->

This will have brought you to the character editor! Let's get started.

## Character Editor

Welcome to Castagne's main tool, the Character Editor! This is where you'll do most of your work. Let's take a quick tour!

<!-- TODO Screenshot -->

<!-- This should have opened up the editor along with your character. Let's take a quick tour: -->
1. The main game window. You can playtest your game here.
2. The code window. This is where you edit your scripts.
3. The reload button, which allows you to load your changes in the game.
4. The state scripts button. You can change the currently edited state through here.
5. The file button. You may change your current file among those loaded through here.
6. The tool window. It can display various tools, but by default it will show you your compilation errors.
7. The flow control buttons. You can restart the situations or control the speed of the game through here.
8. The documentation window. From here you may access this documentation, or get a quick reference of the current function.

You should be able to move around using the arrow keys or WASD, but not attack as we haven't created any attacks yet. Play around with the movement a bit to get comfortable!

This is where I'll introduce Castagne's main way of creating characters: **Castagne Script** (CASP for short)! This is a custom scripting language made with the goal of efficient fighting game character creation. While there are a lot of subtleties and advanced use cases, *I think it's simple enough to handle even with no coding experience*, so please bear with me for a bit!

I'll introduce the concepts one by one, and some tools that make it even easier. In the following code examples, I'll use *comments* to explain some behavior. These start with the '#' character and are ignored by the engine, so you can use them to annotate parts.

If you are already an experienced programmer, you might enjoy reading the [Language Specification](../../index/language)! You'll enjoy the fact that a lot of the behavior is written in CASP, and thus customizable. Let's get started proper!

A Castagne character is always in a **State**: walking, attacking, getting hit... All that behavior is given by **State Scripts**, which is what you'll be making.

You'll see that on the right you have a state script already open: `Character`! This is a special script that holds general data for the character, like the name of the character or its position on the Character Select Screen. This one is filled with a slightly different syntax than the others. Let's start by adding a name:

```
# All parameters we set here are of the form [Parameter Name]: [Value].
# Here, we add a name to display in the game itself.
Name: Baston Jr.

# And here, we add a name that will be shown in the editor!
EditorName: My First Character
```

You can copy that code straight in. You may have noticed that we already have a parameter set: **Skeleton**. Skeletons are additional CASP files you can use as a base. They provide some behavior by default, which you can overwrite if you want to. Castagne already loads a number of them for you depending on the modules / genre selected. You can later add your own Skeleton files to hold behavior like **System Mechanics**. In our case however, this sets up Baston's model and animations for us.

Now let's tune some parameters! A lot of the default behavior can be customized through **Variables**, which are stored inside *Variable blocks*. These start with the `Variables-` prefix and only hold variable definitions. You should already have one defined, but let's see the easy method of edition.

Open up the *Navigation Panel* by clicking on the big button labeled 'Character' on the top right. This will show you the current file's state scripts. Here, we want to *override* an existing one, so we'll need to show it. Click on the "Show All Variables" toggle in the sidebar on the right.

This will show a lot of additional variables blocks! They are in red, meaning they don't belong to the current file. Click once on "Variables-Physics-Basic", then on "Override State" on the right. And there we go, a new Variables block to keep our variables organized!

<!-- TODO Check names of states and variables -->

Let's add a new constant here, to change the walk speed of the character. Copy this line in the code editor, and press "Reload" (or press Ctrl+R) on the bottom of the screen for the changes to take effect:

```
# Let's make him FAST!
def MOVE_Basic_WalkFSpeed int() = 5000
```

Now you might notice the little 5x increase in speed when walking forward if you focus enough, but let's analyze this line in more detail:
- `def`: This small word tells Castagne that this is a *constant*. Constants don't change during the game, and thus are used to keep the parameters you'll want to balance, as opposed to internal variables. You can read the language reference for more information.
- `MOVE_Basic_WalkFSpeed`: This is the name of the constant! Since we're overriding an existing variable, we need its exact name to be taken into account. I'll show you how to find them later!
- `int()`: This is the type of the variable! We have 'int' (Number), 'str' (String of characters), and 'bool' (true/false). In parenthesis, you can add additional data, but this is currently unused.
- `= 5000`: We give a value to the constant! Here that means that the character will move 5000 physics units per frame when walking forward. You can change the value to change the speed!

We now know how to change a variable, but *how can we learn the names and available variables?* While you can read each file's variable blocks, there is an other way, with Custom Editors!

**Custom Editors** are a Castagne feature that allows you to change some code parts with more visual editors! One of their main uses is to alter the constants of a state or variable block. Activate it by clicking on the 'Show Custom Editor' on top of the code window.

> Custom Editors are still in progress, and are meant as a feature both to make some functions easier, and to collaborate better as a team! If your team has a dedicated programmer and dedicated designer, the former can use that to provide parameters to tune for the latter!

You'll see that you can change the variable we just set! But you can also see the list of variables we can override. Search for `MOVE_Basic_WalkBSpeed`, and click on the button to override it! This will add the variable to your current script, and thus allow edition. Change it to another funny value like "-5000", click "Reload".

Now don't hesitate to play with the values for a bit, and override additional ones to further adjust the movement! When you're satisfied, let's go make our first attack!

> If you are using your own model or sprites, you'll need to override the Variables-Graphics blocks! This is what the Baston skeleton is doing for you.




## Our first attack: Straight Jab

> This version of the tutorial assumes you have a bit of basic knowledge about fighting games and numpad notation! In the future, these might be explained in engine.

Finally! Let's write our first attack, a simple standing jab. This is where the fun begins. Start by opening the navigation panel, then press "New State".

This will open up a window allowing you to choose a **State Template**, which help you get started quickly. You can even create your own later! But today we're learning from zero, so select "Empty".

You'll need to choose a name for the attack. While you can put whatever you want, it's a lot easier to use **Numpad Notation**, as it will allow you to register attacks automatically while being clear. By default, Castagne has 4 basic attack buttons: L, M, H, and S, for Light, Medium, Heavy, Special, respectively. We'll do a standing light attack, so name your state '**5L**'.

<!-- TODO: Change basic inputs -->

Now we can add some code! I'll go line by line, and give you the full block at the end. We're going to have to use **Functions**. Let's see the first one!

```
AttackRegister(Light)
```

Let's analyze it. There are two parts: the function name, `AttackRegister`, and in parenthesis, its arguments, separated by commas (`,`). Here we only have one, `Light`. Each function does different things and has different arguments, which you can check in the *Documentation Panel* below if you select a line with that function! Let's see what this one is about.

`AttackRegister` here is a special function that tells Castagne that this state is an attack. It takes two arguments:

- The type of the attack, which are user defined. By default, Castagne provides a few: Light, Medium, and Heavy for normals, Special, EX, and Super for specials, and also has Throw and ThrowFollowup for, well, throws. You can also add 'Air' before any of these for the air version. Here, we will use `Light`.
- The attack's notation. This is an *Optional Argument*, and in this case it will take the current state name. This is why I recommended you to use the notation as a name, otherwise you would have to specify it here.

Functions are given by the modules you load, and you can find the whole list in [the Modules pages](../../modules). They are classified by difficulty, and you can take a look after this tutorial if you want.

Let's continue by specifying some parameters for our attack. We'll use two additional functions to specify the damage and total duration of the attack.

<!-- TODO Mettre des valeurs okay -->
```
AttackDamage(1000)
AttackDuration(30)
```

Simple enough! If you forget the duration, there is a default timeout. But for now we don't see anything! Let's add an animation.

```
Anim(N-BackhandJab)
```

`Anim` will play a previously set animation using Godot's animation player node. Baston has already a few of them available for us, so we'll use this one.

> If you are using sprites, at the moment it's a bit trickier, and you'll use the Sprite function. Let's conitinue with models.

Now, last part. We'll add our hitbox, so that the attack may hit. We however don't want it to be active all the time, so we'll use a branch!

**Branches** are how you control which code gets executed when. There are several types available, each one letter long. Let's see an example :

```
F5:
	# Code to execute if we're on frame 5
else
	# Code to execute if we're NOT on frame 5
endif
```

There are a few parts. Let's see them.

- `F5:`: The actual branch instruction. It is also in three parts.
	- `F`: The branch type. F branches check the current frame (starting at 1), and chooses to execute code at specific times. An other useful type is V, which checks a variable value. Full list is in the [language reference](../../index/language)
	- `5`: Here is the 'condition' for the branch. Since we're in an F branch, this is the frames we want the code to execute in. Here it's frame 5.
	- `:`: Ends the line.
- The code to execute if the condition is valid. This is where we'll put our hitbox.
- `else`: Separates the two code blocks. What is after `else` will be executed if the condition is not fulfilled. In this case, this means all the frames except frame 5.
- The code to execute if the condition is invalid. We don't need anything here for this attack
- `endif`: This closes the branch. What is after that will then be executed regardless of which block we executed. If you forget it, you obtain what we call 'problems'.

Sounds complicated? In practice it's easy to understand. Look:

```
F6-8:
	Hitbox(0, 10000, 5000, 15000)
endif
```

This block means *"Put a hitbox here on frames 6 to 8"*. The F branch can take frame ranges, like 6-8 (meaning frames 6, 7, and 8) or 6+ (meaning frames 6 and up). Then we have the `Hitbox` function, which takes the hitbox's coordinates in order: back, front, down, up. Please note that **the Hitbox function must come after all Attack functions in the script**. This is because it will take the current attack parameters and store it, meaning that if you change a property after, it won't be taken into account.

And we're done! Let's take a look at the final code:

```
# Register it so we can use it
AttackRegister(Light)

# Adjust parameters here
AttackDamage(1000)
AttackDuration(30)

# Put your animation here
Anim(N-BackhandJab)

# Active frames and hitboxes
F6-8:
	Hitbox(0, 10000, 5000, 15000)
endif
```

It's pretty short! How come? That's because **Castagne takes care of some parts automatically**. Let's look at what's going on under the hood:

- We didn't specify a hurtbox, so Castagne adds one automatically for us so that the attack may be counter hit.
- We didn't specify damage proration, but it still works with some default values.
- We also didn't specify any cancels, but they have been added! You'll see when we add more attacks.
- There are plenty of parameters we didn't set, like how much the attack pushes you back, or how much meter you gain on hit. Those also have been set to defaults!

All these are affected by the Attack Type (Light), which is an actual state script you can check! **All those behaviors may be adjusted directly from Castagne Script**, and can be different for each type!

This helps tremendously, as you now don't need to adjust every value, while reducing the risks of errors of manually altering each attack. This tends to be a common thread with Castagne: learn to use it, and it will help you create your game a LOT faster!

If you followed this part correctly, you should be able to use the attack by pressing 'H' or 'Numpad 4' on your keyboard, or 'X' on your controller. Play with the attack for a bit, and when you're ready let's get to the next one!




## Second move: Crouch Jab

So now, we let's continue! A character can have a lot of moves, we'll do two more to get more comfortable with the engine. So let's try another method: for this one, we'll **make it without writing any code**!

We'll do this using some of Castagne's helpers: attack templates and **Custom Editors**. We did use the latter to adjust some variables, and that's pretty much what we'll do here! The idea of Custom Editors is separation of work: one programmer writes the moves while a designer may alter them quickly. That way, both can work where they are needed the most!

In this case, we'll use an attack template to write us a quick piece of code, bypassing that programmer. This uses the **SimpleAttack** family of helpers, we'll see how they work just after this, but for now, let's make it! Follow these steps:

- Click on 'Use Custom Editors' if it's not already active
- Open the navigation panel
- Click on 'New State'
- Select the 'Attack-Simple' template. Name the state '2L' and press confirm.

And there you go! You have your attack, some parameters already out for you. Let's fill them! Here are my values, don't hesitate to alter them.

- Damage: 1000
- Animation: N-CrouchJab
- Startup: 7
- Active Frames: 3
- Recovery: 20
- Hitstun: 35
- Frame Advantage Block: 2
- Hitbox:
	- Back: 0
	- Front: 12000
	- Bottom: 0
	- Top: 12000

<!-- - Crouching
- MomentumX -->


> Please note that at the time of this writing (v0.53.1), the hitbox visualization in this specific context is not implemented. For now you have to go with your gut!

Try it out for yourself, by pressing down and L ('H' or 'Numpad 4' on your keyboard, or 'X' on your controller)! Once again Castagne takes care of a lot under the hood, so you can even start canceling attacks into each other! This is done by using 2L when 5L hits, which will skip the rest of the attack.

While we could stop there, there's no magic to this system. Let's take a look behind the scenes. Deactivate the custom editor by clicking on 'Use Custom Editors', and you'll see that it's just variable declarations! Indeed, you can create constants inside a state to be able to use them both in the code and custom editor. Those you make here will only be used in this state. Here's the code if you're following at home and not in the engine (which you should download and open!):

```
def Attack_Damage int() = 1000
def Animation_Name str() = N-CrouchJab

def Attack_Startup int() = 7
def Attack_ActiveFrames int() = 3
def Attack_Recovery int() = 20
def Attack_Hitstun int() = 35
def Attack_FrameAdvantageBlock int() = 2
def Hitbox_Front int() = 12000
def Hitbox_Bottom int() = 0
def Hitbox_Top int() = 12000

# Template for attacks you can customize through custom editors.
# /!\ This is still limited! Some improvements need to be made to achieve it fully, so you need a bit of manual editing still at times.
AttackRegister(Medium)

Call(SimpleAttack-Standard)
```

If you take a closer look, we don't actually do anything here. It's in fact all hidden inside this line: `Call(SimpleAttack-Standard)`. Let me show you a sample of its code:

```
def Attack_Damage int() = 1000
def Animation_Name str() = 5B

AttackDamage(Attack_Damage)
Anim(Animation_Name)
```

It's... just giving the parameters directly! Alright, that one is just a sample, there's a bit of math to make the interface easier, but it's pretty much what it does! The way it works is that, if **a state with a variable V calls a state that also has same variable V, the called state's variable will be overwritten** (static calls only). Basically, by having a variable called `Attack_Damage` in our 2L, it will override the value of SimpleAttack-Standard's `Attack_Damage`.

So in practice, making attacks without code is simple! So **why does Castagne have code, and why isn't this the default?** It's simply because **if you expose all parameters, it becomes too complex**. Already with the simplest of attacks, you can have more than 20-30 parameters, and if you add what's under the hood? That's way too much, we'll get lost trying to find what we're looking for. Doing attacks this way would also be limited, because as soon as you want to do something that's a bit more special, you balloon all of this exponentially!

This is why **I recommend using code** and **exposing only some variables like this**. Stuff you'll know might get touched more often, like *Damage* or *Movement*, while internal logic should probably stay, well, internal. This is when you'll get true value out of Custom Editors, when your designers can quickly tune values.

Still, you saw code, you saw this system. You can use these helpers if you want to! Because it's not on the critical engine path and more aimed at beginners, your feedback is appreciated!


## Third move: Jumping Bat Swing

<!-- TODO: Troisieme attaque dans les airs, State comment et flag TODO -->

Alright, last move for today! This one is an air move, and because you now know the basics we'll focus on some more advanced aspects.

We'll name the move `j5H`. The 'j' means jumping! This will be picked up by the engine and automatically allow us to use it in the air. Use the empty template.

Let's make this a bit friendlier. Add this line to the code, and Reload (Ctrl+R):

```
## Downwards bat swing with a sweetspot at the end of the bat.
## TODO Add the hitboxes
```

See that we started not with just one '#', but two? This is a **State Comment**, which will show up in the navigation panel when you click on a state! This helps communicate information and place stuff to remember. The first line will show under the

You might also have seen the small 'TODO' icon. This is a **State Flag**, and they allow you to find states quickly by filtering! Some are already defined for you and you can see them in the navigation panel, and you can make your own with `_StateFlag`, even if it doesn't have an icon yet. 'TODO' is a special flag, which appears if you have a 'TODO' in your state comments! All of Castagne's base states are labeled like this, so you can find what you need.

You might also have noticed the 'Warning' icon. Castagne tries to help you limit mistakes by analyzing your code a bit, and alerts you with warnings when it finds something fishy! You can see that we have one, by both the State Flag, but also the 'Code Warning' button under the code window. Here, it says our state is incomplete, which is true. Let's fix it!

Let's register this as an **AirHeavy attack**. The 'Air' is important because it handles landing. Let's add some parameters while we're there, you already know them.

```
AttackRegister(AirHeavy)
AttackDamage(1200)
AttackDuration(50)

```

Before adding the hitbox, let's make this air attack a proper **Overhead**, which means it can't be blocked crouching. We'll do this with an additional function: `AttackFlag`, which allows us to mark attacks with some properties. Attack flags can be read by the attacked character, and thus change its behavior.

```
AttackFlag(Overhead)
```

This will also add a small AttackOverhead flag so you can find them more easily! The same works with 'Low', the opposite of overhead. You can technically also put it on an air attack, if you want to frustrate players.

We can always add more properties, but let's not overwhelm ourselves. Let's add a **sweetspot** to the move and call it a day! In order to do that, we'll have to understand how attacks and hitboxes interact: **Hitboxes will copy the current attack parameters**, which is why **they only take what happens before them into account**.

This means that we don't need to rewrite all parameters each time! You can put two hitboxes one after the other and they'll be the same. But if we sneak a few functions inbetween the two, we'll get altered properties! This is what we'll use. Let's make a sweetspot with increased damage that knocks down (this system is explained in the next page, but it's really obvious when you touch the sweetspot so just copy that for now).

```
F9-12:
	# Sourspot
	Hitbox(0, 7000, -2000, 10000)

	# Sweetspot
	AttackDamage(5000)
	AttackKnockdown()
	AttackFlag(ForceLanding)
	Hitbox(5000, 12000, -1000, 10000)
endif
```

The order of the two is important, because **Castagne will prioritize the first hitbox**. This means that here, if both hitboxes touch, the sourspot will prevail. If we declared the sweetspot first, it would be the opposite.

Try it out! Press 'K' or 'Numpad 6' on keyboard or 'B' on controller, while in the air to do the attack. You'll need to touch with the tip of the bat to get the knockdown! Here's the full code.

```
## Downwards bat swing with a sweetspot at the end of the bat.

AttackRegister(AirHeavy)

AttackDamage(1200)
AttackDuration(50)
Anim(N-AirSwing)

AttackFlag(Overhead)


F9-12:
	# Sourspot
	Hitbox(0, 7000, -2000, 10000)

	# Sweetspot
	AttackDamage(5000)
	AttackKnockdown()
	AttackFlag(ForceLanding)
	Hitbox(5000, 12000, -1000, 10000)
endif
```


Aaaaaand we're done! You now know how to make some basic attacks in Castagne! Take a break if you feel like it, because you deserved it! This was a fair amount of information, but it will become second nature with time.

When you're ready, we'll get over some additional properties on the next page so that you can spice up your moves!
