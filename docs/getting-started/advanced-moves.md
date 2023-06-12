---
title: Advanced Moves
order: 5000
todo: 54
---

<!-- TODO Throws -->

<!-- TODO Knockdown -->
<!-- TODO Momentum / Float -->

# Advanced Moves

This section gives a few tips and examples on how to do more complex moves, to help you get started.

> In progress

## Move Properties
This category focuses on specific parts that can happen in a lot of different attacks.

### Low / Overheads / Unblockables
<!-- TODO -->

```
AttackFlag(Low)
AttackFlag(Overhead)

AttackFlag(GroundUnblockable)
AttackFlag(AirUnblockable)
```

### Moving attacks
<!-- Moving attacks, like Castagneur's *Slide Heel* (3C) -->
Moving attacks, like Castagneur's 5B, include some sort of movement. This can be done in two, non-exclusive ways:
- You can use the `Move` function to move directly. This is very precise, but can feel very stiff.
- You can use the `AddMomentum` / `SetMomentum` function to start a smoother movement, but this is subject to the restrictions of momentum, meaning total distance is affected by friction and can be carried into other moves (it is possible to control this behavior in detail but it is more complex).

You may also use both to have a smoother part and one easier to adjust, while limiting the amount of carried momentum, depending on the target game feel.

```
# This one is for fixed movement
F4-8:
	Move(800, 0)
endif

# This one is to give an impulse that will stay over the next few frames
F4:
	AddMomentum(1000)
endif

# You can combine both or use either depending on your target game feel.
```

### Multihitting moves
<!-- like Castagneur's *Crazy Leg* (6C) -->
Multihitting moves, like Castagneur's 4C counter, are characterized by the ability to hit several times.

This is often achieved by the `AttackRearm` function, which resets the hit logic that prevents someone being hit twice by the same attack. Be careful, as it also removes the triggers that were raised from that, meaning you might be able to cancel before the end of the attack if you don't restrict it.

```
# First Attack
AttackDamage(1000)
AttackDuration(35)
F6-7:
	Hitbox(0, 15000, 0, 22000)
endif

# This should only be called once to reset the hit logic, otherwise you might hit on every frame.
F17:
	AttackRearm()
endif

# Second attack
F17-18:
	AttackDamage(2000)
	Hitbox(0, 16000, 0, 23000)
endif
```


### Knockdown
<!-- Castagneur's *Batdown (Uncharged)* (4D) -->
Castagneur's 4D (uncharged) is an example of one. By using `AttackKnockdown`, you can force a knockdown on landing. A few things to note:
- By default, with no parameters, it will knockdown the opponent for a period specified by the Castagne config.
- If using one parameter, it will still allow for a variable length knockdown derived from those same parameters.
- If using two parameters, it will allow variable tech timing between those two numbers. Use twice the same for an hard knockdown.
- Knockdown only activated on landing. Use the `ForceLanding` attack flag to force a knockdown on the ground.
<!-- TODO -->
```
F20-24:
	# This forces a knockdown of specified duration. With only one parameter, the knockdown's duration can be controlled by the person hit.
	AttackKnockdown(30)

	# Knockdown only works on landing. This flag forces it even when the opponent is grounded
	AttackFlag(ForceLanding)

	Hitbox(0, 16000, 0, 18000)
endif
```

### Ground Bounce
<!--Castagneur's *Batdown (Charged)* (4[D])-->
Castagneur's 4D (Charged) is again an example of that. The rules are the same as `AttackKnockdown`, but this time with `AttackGroundbounce`. The parameters control the length and height of the ground bounce.
<!-- TODO -->

```
F30-34:
	# This will activate a ground bounce of specified duration and momentum if still within the limit.
	AttackGroundbounce(60, 1600)

	# Float is useful to control the height of the bounce better.
	AttackFloat(40)

	# This forces a knockdown of specified duration, when the ground bounce doesn't happen.
	AttackKnockdown(30)

	# Knockdown/Groundbounce only works on landing. This flag forces it even when the opponent is grounded
	AttackFlag(ForceLanding)

	Hitbox(0, 16000, 0, 18000)
endif
```

### Sweetspots
<!--Castagneur's *Justice Elbow* (jD)-->
Some moves have sweetspots where depending on by what part of the hitbox you are hit, the properties of the attack change.
The simplest way to do that in Castagne is to take advantage of the priority of hitboxes, where the final registered attack is the one belonging to the first declared hitbox.

```
# Sweetspot
AttackDamage(2000)
Hitbox(500, 600, 500, 600)

# Sourspot
Attack(500)
Hitbox(-5000, 5000, 0, 20000)
```

### Launchers / Special Gravity
<!-- Castagneur's *Sky Bunt* (2C) -->
Some attacks, like Castagneur's 2B, are made to launch an opponent in the air or make him trip. You want to add upwards momentum on hit only but not block, using `AttackMomentumBlock`, and maybe adjust your hitstun gravity temporarily using `AttackFloat`.

```
F10-12:
	# AttackMomentum allows us to determine how much the opponent will be pushed. Having a positive value in the second slot will launch him upwards.
	AttackMomentumHit(700, 1400)

	# However, we don't want this to happen on block, we want the opponent to stay grounded. We use this to set the momentum on block specifically.
	AttackMomentumBlock(700, 0, 500, 900)

	# This allows setting a custom gravity on hit, which allows more fine grained control of the launch
	AttackFloat(50)

	Hitbox(0, 16000, 0, 5000)
endif
```

<!-- ### Hopping Moves / Air-to-Ground / Ground-To-Air -->
<!--Castagneur's *Thief Tackle* (6D)-->
<!-- Some moves change if they are grounded or not during their execution. This can be done by using `VariableAttack` instead of `AirborneAttack` or `StandingAttack`. Additionally, the flags `PFGrounded` and `PFAirborne` may be used to determine if we are grounded or not.

```
# If we used airborne or standing attack, it would be cancelled automatically on landing/take off.
Call(VariableAttack)

# Initiate a hop
F1:
	AddMomentum(3000, 1000)
endif

# Brake when on the ground.
LPFGrounded:
	BreakMomentumX(300)
endif

``` -->






## Special moves

### Throw
Throws are a major part of fighting games, but can be quite complex to implement. Castagne already has an helper for that that will take care of:
- Initializing the throw / airthrow parameters
- Manage throw teching
- Managed tech lockout
- Manage the choice between front/back throw
- Automatically make a back throw if you only have a front throw.

These can be parametrized through the `Variables-Attacks-Throws` block.

You need to create two moves, the first being the actual throw startup / throw whiff state. Castagne has a 'Throw' input macro, so call your throw '5Throw'.

```
# This will also initialize an attack, so you only need to put down a hitbox.
AttackRegister(Throw)

# This is your total animation time when whiffing.
AttackDuration(30)

# This is the hitbox that throws.
F8-10:
	Hitbox(0, 10000, 0, 20000)
endif
```

The second is the actual throw. It needs to be referenced by name in the file, the default being `ThrowF`. This works like any other attack, with the type ThrowFollowup.

```
AttackRegister(ThrowFollowup)

AttackDamage(1000)
AttackDuration(30)
AttackKnockdown(50,50)
AttackFlag(ForceLanding)

F8:
	Hitbox(0, 20000, 0, 20000)
endif
```

You can also make ThrowB, but by default it will just use ThrowF but flipped.

### Projectiles
Baston's *Staight Pitch* (5S) is a projectile. They can be tricky to manipulate, as it requires making a new entity.

Let's start by creating the projectile proper. Click 'New Entity' in the navigation panel, and select the 'Projectile' template. Call it 'Ball'. This will create a sub entity in your CASP file, for which you can add new states by prefixing them with 'Ball--'

Now you're in the 'Init--Ball' state, which will initialize the projectile. You can use Custom Editors to change the values given to `Init-LightGraphicsInit`, which will create the model.

Next, go to 'Ball--Action', the main state of the projectile. Once again, use custom editors to change it to your liking.

Now let's make the actual state. In 'New State', select the 'Attack-Projectile' move and call it '5S'. Use the custom editor to replace the `ProjectileName` variable with `Ball`, and there you go!

```
# For reference, this is how you create your projectile after that
CreateEntity(ProjectileName)
SetTargetPosition(ProjectileStartX, ProjectileStartY)
```

You can make complex projectiles by expanding on this, or even puppets.

### Reversals / Counters / Attribute Invulnerability / Guard Points (Anti-air, Low crush...)
<!--Castagneur's Castagneur's *Counter Bunt* -->

Some attacks are invincible to other attacks, or specific types of attacks. Others may react to being attacked. This can all be managed through the attribute system:
- Each attack has an attribute associated to it. By default, it is set automatically.
- You can become invincible or guard against attacks of a specific attribute through the `Invul-[ATTRIBUTE]` and `Guard-[ATTRIBUTE]` flags.
	- The difference between the two is that `Invul` will treat it as an attack whiffing, and `Guard` as an attack being blocked (and thus allows the attacker to continue as if it was a blockstring).
	- Default attributes are `Mid, High, Low, Air, Projectile, Throw, AirThrow`, but you can add yours without any more code. You may also use `All` to cover all attributes.
	- You can react to dodging an attack this way by checking the `Invuled` and `Guarded` flags. On guard, you also can check the values of the attack you guarded through.

Here's an example using Castagneur's 4C counter.
```
F1-12:
	# Can use Guard-All if you don't need to discriminate against a specific one, but here we want to be vulnerable to lows and throws.
	Flag(Guard-High)
	Flag(Guard-Mid)
	Flag(Guard-Air)
	Flag(Guard-Projectile)
endif

# Check if we got hit, and thus transition into the counter.
LGuarded:
	Transition(4C-CounterConfirmed)
endif
```

> Note that for full invulnerability, not adding an hurtbox also works. Removing parts of the hurtbox (like making an attack have an hurtbox only on the legs) may also work but lead to different interactions and gamefeel. Since there is a helper for the standard hurtbox, use the flag 'NoHurtbox' to skip it.

### Autocombos / Rekkas / Unchain
<!-- like Castagneur's *Jab and Swing* -->
Some attacks, like Castagneur's autocombo, are composed of multiple parts, that might even branch out from one to the next. The easiest way to manage those is through the cancel system.

<!-- TODO vérif les noms -->
The functions you are looking for are the `AttackCancel` function. It takes an input in numpad notation and a move, and by using that you can override the regular use of the button. Add only one for rekkas / autocombos, or several for unchains. By default, this will be subject to the cancel system, meaning you can't use the same attack twice. You can give a third parameter for the situation, using the `ATTACKCANCEL_ON_` family of constants.


```
F9+:
	# This tells the cancel system to do 5AA if we pressed 5A, allowing for a smooth easy chain, even on whiff.
	AttackCancel(5AA, 5A, ATTACKCANCEL_ON_TOUCH_AND_WHIFF)
endif
```
> The constants are not implemented propertly right now, so you need to use the actual value you can find in the docs for now. ATTACKCANCEL_ON_TOUCH_AND_WHIFF is 7.
<!-- TODO -->

### Held Moves
<!--Castagneur's *Batdown* (4D)-->
<!-- TODO -->
Some moves can change their duration depending on how much they are held, like Castagneur's 4D. There are several ways to manage that depending on wanted results, but I tend to favor using flags for their ease of local use. The method is to declare a flag that will stay from one frame to the next, and remove it when we're not holding the button anymore.

If the move is simply delayed, the easiest way is to transition to a second part.

```
# Initialize the flag
F1:
	Flag(HeldVersion)
endif

# Check if we are still holding the button, and if not uncheck the flag
IA:
else
	Unflag(HeldVersion)
endif

# Propagate the flag to the next frame
LHeldVersion:
	FlagNext(HeldVersion)
endif

# If releasing during this window, do the attack's second part
F12-25:
	LHeldVersion:
	else
		Transition(SecondPart)
	endif
endif

# Force the attack after a while
F26:
	Transition(SecondPart)
endif

```

If you are choosing between two version (like Castagneur's 4D), you can simply have a smaller window to check which branch to go to and adapt depending on the flag's value. (You can also use transitions to change the move if prefered).

```
# Holding logic ---

# Start by raising a flag, if that flag is still up at the end of the charge window we will do the charged version.
F1:
	Flag(HeldVersion)
endif

# Window to stop charging. Doesn't start immediately to give a small buffer to the player, stays until the animation would start.
# Once we reach frame 15, we are locked in whichever version the player chose.
F4-14:
	ID:
	else
		# If D is released, stop charging.
		Unflag(HeldVersion)
	endif
endif

# Carry over the flag to the next frame
LHeldVersion:
	FlagNext(HeldVersion)
endif

# ------------

LHeldVersion:
	# Held version
	F30-34:
		AttackDamage(1500)
		AttackDuration(55)
		Hitbox(0, 16000, 0, 18000)
	endif
else
	# Unheld version
	F20-24:
		AttackDamage(1000)
		AttackDuration(45)
		Hitbox(0, 16000, 0, 18000)
	endif
endif
```
