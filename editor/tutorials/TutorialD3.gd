extends "TutorialBase.gd"


func TutorialScript():
	charEditor = editor.get_node("CharacterEdit")
	
	system.ContinueNextFrame()
	yield()
	
	var navigationPanel = charEditor.get_node("CodePanel/Navigation")
	var popupNewState = charEditor.get_node("Popups/Window/NewState")
	var newStateButton = navigationPanel.get_node("ChooseState/Menu/NewState")
	
	var codeWindow = editor.get_node("CharacterEdit/CodePanel/Code")
	var customEditor = charEditor.get_node("CodePanel/CustomEditor")
	var headerStateButton = editor.get_node("CharacterEdit/CodePanel/Header/State")
	
	var battleInitData = editor.configData.GetBaseBattleInitData()
	battleInitData["players"][1]["entities"][1]["scriptpath"] = "user://tutorial/TutorialBaston.casp"
	battleInitData["players"][1]["inputdevice"] = "k1"
	editor.StartCharacterEditor(false, battleInitData)
	system.ContinueNextFrame()
	yield()
	
	var code = codeWindow.get_text() +"\n"
	
	system.ShowDialogue("""Hey! Welcome back! This time we will get to making some actual moves!

We will make three of them here, to really understand the process.""")
	yield()
	
	system.ShowDialogue("""First, let's make a standing jab!

Let's open the navigation panel!""")
	system.StencilNode(headerStateButton)
	yield()
	
	charEditor.On_Header_State_Pressed()
	system.ShowDialogue("""Now, press 'New State'.""")
	system.StencilNode(newStateButton)
	yield()
	
	system.PressButton(newStateButton)
	system.ShowDialogue("""In this window, we can create a new state using templates (you can even create your own templates!). We won't use any in order to learn, so let's use 'Empty'.""")
	system.StencilNode(popupNewState)
	yield()
	
	system.ShowDialogue("""The name can be important. If you use a name in numpad notation, it will be easier to find and register.

Our buttons here are (L)ight, (M)edium, (H)eavy, and (S)pecial, so let's call it 5L!""")
	system.StencilNode(popupNewState)
	yield()
	
	charEditor.HidePopups()
	navigationPanel.hide()
	code = ":Character:\n"+code
	code += "\n:5L:\n"
	system.SetCode(code)
	var codeMove = ""
	charEditor.ChangeCodePanelState("5L")
	system.ShowDialogue("""Now we get into real Castagne Script territory! You'll see it's easy enough.""")
	system.StencilNode(codeWindow)
	yield()
	
	codeMove += "AttackRegister(Light)\n\n"
	codeWindow.set_text(codeMove)
	system.ShowDialogue("""Castagne script works with functions, which follow the structure of Name(Argument 1, Argument 2...). Each function will do different things and take different arguments.""")
	system.StencilNode(codeWindow)
	yield()
	
	system.ShowTopDialogue("""You can look at the bottom of the editor to see the list of arguments and what each function does!

You can also find the list of functions inside the Documentation, accessible through the button.""")
	system.StencilNode(charEditor.get_node("CodePanel/Documentation"))
	yield()
	
	system.ShowDialogue("""Here, AttackRegister will do two things:
1. Register our attack inside the attack system, which will allow us to use it.
2. Execute some basic code to make it functional.""")
	system.StencilNode(codeWindow)
	yield()
	
	system.ShowDialogue("""It takes up to two arguments. The first is the attack type, which can be one of few: Light, Medium, Heavy, for normals, Special, EX, Super, for specials, and Throw, ThrowFollowup, for throws, along with Air variations. You can make your own!
The second is the notation to use it. If you don't specify, it will take the state name, 5L in our case!""")
	system.StencilNode(codeWindow)
	yield()
	
	codeMove += "AttackDamage(1000)\nAttackDuration(30)\n\n"
	codeWindow.set_text(codeMove)
	system.ShowDialogue("""Next, let's customize our attack. AttackDamage will allow us to set damage values, and AttackDuration the total length. This is going to appear in pretty much all attacks.""")
	system.StencilNode(codeWindow)
	yield()
	
	system.ShowDialogue("""Then we will want to add a hitbox, but we can't keep it active all the time. We need branches!

A branch controls which code is executed when. Let's see what they look like.""")
	system.StencilNode(codeWindow)
	yield()
	
	codeWindow.set_text(codeMove+"F5:\n\t# Code to be executed on frame 5\nelse\n\t# Code to be executed on all frames except 5\nendif\n")
	system.ShowDialogue("""Branches follow the a structure of one letter for the type, the condition, and the ':' symbol. If the condition is fulfilled, the code will be executed until the 'endif' keyword.

You can also use the 'else' keyword in the middle, to do code when the condition is NOT fulfilled.""")
	system.StencilNode(codeWindow)
	yield()
	
	system.ShowDialogue("""Here this is an F branch, which checks for the current frame of the state. Castagne assumes 60FPS by default and states start at Frame 1.

It is followed by which frame you want (5), or a range (5-8 for frames 5, 6, 7, and 8 ; or 5+ for frames 5 and up).""")
	system.StencilNode(codeWindow)
	yield()
	
	codeMove += "F6-8:\n\tHitbox(0, 12000, 7000, 17000)\nendif\n\n"
	system.SetCode(code + codeMove)
	system.ShowDialogue("""Here we will add an hitbox from frames 6 to 8. The Hitbox function takes the back, forward, bottom, and top bounds of the box.

The editor will show you where it will be, this is called a Gizmo! You can hide them.""")
	system.StencilNode(codeWindow)
	yield()
	
	codeMove += "Anim(N-BackhandJab)"
	codeWindow.set_text(codeMove)
	system.ShowDialogue("""Finally, let's add an animation, with the Anim function. Baston has a few, we'll use N-BackhandJab.""")
	system.StencilNode(codeWindow)
	yield()
	
	system.ShowDialogue("""And that's it! We have a full attack! Try it out a bit in the engine by using either the H key on your keyboard, or Numpad 4, then we will analyse a bit.""")
	yield()
	
	code += codeMove +"\n\n"
	
	system.StartCoding("""Try out the jab by pressing H or Numpad 4!""", code)
	yield()
	
	
	
	
	
	
	
	
	system.ShowDialogue("""You'll have noticed that we haven't wrote down a lot. This is because Castagne will do quite a bit behind the scenes from CASP. Here, it managed adding a hurtbox, default attack parameters like hitstun or proration, and even cancels! Those can all be customized or disabled.""")
	yield()
	
	system.ShowDialogue("""I hope you can apprehend it better now! Let's do it with a twist for the next one, we'll do it with NO code! We'll use the Custom Editors once again.

This one will be the crouching jab, 2L!""")
	yield()
	
	var customEditorButton = charEditor.get_node("CodePanel/UseCustomEditor")
	customEditorButton.set_pressed_no_signal(true)
	customEditorButton.emit_signal("pressed")
	system.ShowDialogue("""Let's start by activating the Custom Editors here.""")
	system.StencilNode(customEditorButton)
	yield()
	
	charEditor.On_Header_State_Pressed()
	system.ShowDialogue("""Then we move to the navigation panel, and create a new state.""")
	system.StencilNode(newStateButton)
	yield()
	
	system.PressButton(newStateButton)
	system.ShowDialogue("""We will select the 'Attack-Simple' which is a special, experimental use of the engine's features.""")
	system.StencilNode(popupNewState)
	yield()
	
	code += "\n:2L:\n"
	codeMove = """# Template for attacks you can customize through custom editors.
# /!\\ This is still limited! Some improvements need to be made to achieve it fully, so you need a bit of manual editing still at times.
AttackRegister(Medium)

Call(SimpleAttack-Standard)
"""
	charEditor.HidePopups()
	navigationPanel.hide()
	system.SetCode(code + codeMove)
	charEditor.ChangeCodePanelState("2L")
	system.ShowDialogue("""And there we are! You can see parameters available already. Let's override some!""")
	system.StencilNode(customEditor)
	yield()
	
	codeMove = """def Attack_Damage int() = 1000
def Animation_Name str() = N-CrouchJab

def Attack_Startup int() = 7
def Attack_ActiveFrames int() = 3
def Attack_Recovery int() = 20
def Attack_Hitstun int() = 35
def Attack_FrameAdvantageBlock int() = 2
def Hitbox_Front int() = 12000
def Hitbox_Bottom int() = 0
def Hitbox_Top int() = 12000

""" + codeMove
	system.SetCode(code + codeMove)
	system.ShowDialogue("""I went ahead and put some variables in. Play with it yourself, then we'll take a look behind the curtain!

Use the attack by pressing down and H or numpad 4! You can also cancel it from 5L.""")
	system.StencilNode(customEditor)
	yield()
	
	code += codeMove
	system.StartCoding("""Try out the crouching jab by pressing down (down arrow or S) and Light (H or Numpad 4)! You can cancel into it from 5L.

Don't hesitate to change the parameters and reset if you are lost!""", code)
	yield()
	
	system.ShowDialogue("""Now let's see how it works!""")
	yield()
	
	customEditorButton.set_pressed_no_signal(false)
	customEditorButton.emit_signal("pressed")
	system.ShowDialogue("""And... it's almost nothing! It's just variable declarations! That's because all the behavior is in that line: Call(SimpleAttack-Standard).

You can declare constants in regular state scripts, and override those from the states you call!""")
	system.StencilNode(codeWindow)
	yield()
	
	system.ShowDialogue("""The code inside is very simple, it's just passing those variables along. So the question is, why isn't the whole engine like this?

The simple answer: Flexibility and Information Density.""")
	system.StencilNode(codeWindow)
	yield()
	
	system.ShowDialogue("""If you take any attack, it can have lots of different variables. Even the simplest of attacks can have 20+ parameters EASILY. If we show all of them, we won't see anything!
This problem becomes even worse the more you want specific behavior, all attacks would become unmanageable with hundreds of parameters.""")
	yield()
	
	system.ShowDialogue("""That's why I would recommend using code as a base, and variable declarations for select parameters, especially in teams.
As an example, maybe a jumping kick that transitions to another on block doesn't need that behavior as parameters, as it won't change often, but the damage and movement might be adjusted more often by designers. Feel it out!""")
	yield()
	
	system.ShowDialogue("""In the end, what you do is up to you and your team. Everybody's circumstances are different.
A game developped by a single engine expert, one developped by a team of 12 pros, and one by a gang of three friends for fun will have different needs.
That's why Castagne's tools stay flexible, to have the ability to be fitted.""")
	yield()
	
	system.ShowDialogue("""Enough deeper engine philosophy for now, let's do one last attack!

This time since we're more used to it, we will do a more complex attack with a more normal workflow.""")
	yield()
	
	charEditor.On_Header_State_Pressed()
	system.PressButton(newStateButton)
	system.ShowDialogue("""Once again, open navigation panel, select new state, but this time we're going to use an attack template.

We will do an air bat swing, j5H. The j is for jumping, which allows us to register it in the air.""")
	system.StencilNode(popupNewState)
	yield()
	
	code += "\n:j5H:\n"
	codeMove = """# Simple medium attack template
AttackRegister(Medium)

# Adjust parameters here
AttackDamage(1000)
AttackDuration(60)
# AttackFlag(Low)

# Put your animation here
#Anim(5B)

# Active frames and hitboxes
F10-12:
	Hitbox(0, 15000, 5000, 15000)
endif

"""
	charEditor.HidePopups()
	navigationPanel.hide()
	system.SetCode(code + codeMove)
	charEditor.ChangeCodePanelState("j5H")
	system.ShowDialogue("""There we are. Let's start with a simple modification: the attack type. With the template, it's a Medium, we'll make in an AirHeavy.""")
	system.StencilNode(codeWindow)
	yield()
	
	codeMove = """## Downwards bat swing with a sweetspot at the end of the bat.
## TODO: Finish the attack!
AttackRegister(AirHeavy)

# Adjust parameters here
AttackDamage(1000)
AttackDuration(60)
# AttackFlag(Low)

# Put your animation here
#Anim(5B)

# Active frames and hitboxes
F10-12:
	Hitbox(0, 15000, 5000, 15000)
endif

"""
	system.SetCode(code+codeMove)
	system.ShowDialogue("""Let's add a special comment to our attack! By starting a line with ##, the comment will be shown in the navigation panel. Let's reload and see what it does!""")
	system.StencilNode(codeWindow)
	yield()
	
	charEditor.On_Header_State_Pressed()
	system.ShowDialogue("""Thanks to that, when you select it, it now displays the first line under the name! You can also find its full documentation at the bottom.

The TODO also added a small icon next to it. This is called a State Flag! You can make your own, some are added automatically. You can filter nodes quickly with it, so if you want to find all your TODOs, just press the button on the right side of the panel!""")
	system.StencilNode(navigationPanel)
	yield()
	
	navigationPanel.hide()
	codeMove = """## Downwards bat swing with a sweetspot at the end of the bat.
## TODO: Finish the attack!
AttackRegister(AirHeavy)

# Adjust parameters here
AttackDamage(1000)
AttackDuration(40)
# AttackFlag(Low)

# Put your animation here
Anim(N-AirSwing)

# Active frames and hitboxes
F9-12:
	Hitbox(0, 15000, 5000, 15000)
endif

"""
	codeWindow.set_text(codeMove)
	system.ShowDialogue("""Let's get back to the attack. I've added filled out the damage, duration, active frames, and animation. It's an air attack however, so let's make it an overhead.""")
	system.StencilNode(codeWindow)
	yield()
	
	codeMove = """## Downwards bat swing with a sweetspot at the end of the bat.
## TODO: Finish the attack!
AttackRegister(AirHeavy)

# Adjust parameters here
AttackDamage(1000)
AttackDuration(40)
AttackFlag(Overhead)

# Put your animation here
Anim(N-AirSwing)

# Active frames and hitboxes
F9-12:
	Hitbox(0, 15000, 5000, 15000)
endif

"""
	codeWindow.set_text(codeMove)
	system.ShowDialogue("""To do that, we use the AttackFlag function, which allows us to signal properties to the reciever. We'll send the Overhead flag, which ensures we can't block it low.

Other flags include Low and GroundUnblockable for instance, but you can also create your own!""")
	system.StencilNode(codeWindow)
	yield()
	
	system.ShowDialogue("""Let's get tricky: we'll add a sweetspot to the attack. We will need to understand how Castagne handles hitboxes for that.""")
	system.StencilNode(codeWindow)
	yield()
	
	system.ShowDialogue("""During all the script, you prepare a potential attack. All Attack functions will change this attack, but it doesn't exist until we make an hitbox.

The hitbox will take the current prepared attack, and copy it to this hitbox. This is why you want your hitbox function to come last, so that all its parameters are set beforehand.""")
	system.StencilNode(codeWindow)
	yield()
	
	
	codeMove = """## Downwards bat swing with a sweetspot at the end of the bat.
## TODO: Finish the attack!
AttackRegister(AirHeavy)

# Adjust parameters here
AttackDamage(1000)
AttackDuration(40)
AttackFlag(Overhead)

# Put your animation here
Anim(N-AirSwing)

# Active frames and hitboxes
F9-12:
	# Sourspot
	Hitbox(0, 7000, -2000, 10000)
	
	# Sweetspot
	Hitbox(5000, 12000, -1000, 10000)
endif

"""
	codeWindow.set_text(codeMove)
	system.ShowDialogue("""The potential attack stays the same, so you can continue adding hitboxes. These will be the same attack with the same parameters.

But what if several hitboxes hit? Castagne will only take the first. And this is where we'll use that property.""")
	system.StencilNode(codeWindow)
	yield()
	
	codeMove = """## Downwards bat swing with a sweetspot at the end of the bat.
## TODO: Finish the attack!
AttackRegister(AirHeavy)

# Adjust parameters here
AttackDamage(1000)
AttackDuration(40)
AttackFlag(Overhead)

# Put your animation here
Anim(N-AirSwing)

# Active frames and hitboxes
F9-12:
	# Sourspot
	Hitbox(0, 7000, -2000, 10000)
	
	# Sweetspot
	AttackDamage(5000)
	Hitbox(5000, 12000, -1000, 10000)
endif

"""
	codeWindow.set_text(codeMove)
	system.ShowDialogue("""If we add some Attack functions between the two Hitboxes, only the second will have those new parameters. This means that we can create that sweet/sourspot!

The order here is important, as the first attack will take priority. Here, the sourspot is prioritized, so you'll need to hit with the tip of the bat to use it.""")
	system.StencilNode(codeWindow)
	yield()
	
	codeMove = """## Downwards bat swing with a sweetspot at the end of the bat.
## TODO: Finish the attack!
AttackRegister(AirHeavy)

# Adjust parameters here
AttackDamage(1000)
AttackDuration(40)
AttackFlag(Overhead)

# Put your animation here
Anim(N-AirSwing)

# Active frames and hitboxes
F9-12:
	# Sourspot
	Hitbox(0, 7000, -2000, 10000)
	
	# Sweetspot
	AttackDamage(5000)
	AttackKnockdown()
	AttackFlag(ForceLanding)
	Hitbox(5000, 12000, -1000, 10000)
endif

"""
	codeWindow.set_text(codeMove)
	system.ShowDialogue("""In order to make it more obvious, let's add a knockdown! This will put the opponent in a Knockdown state of specified length on landing. If we don't specify, it will be a default value soft knockdown.

In order to force it on the ground, we also add AttackFlag(ForceLanding).""")
	system.StencilNode(codeWindow)
	yield()
	
	system.ShowDialogue("""And this should be good enough for an attack! Play with it a bit, and then we'll conclude.

You can use the attack by pressing K or Numpad 6 in the air. Try it out with a neutral jump to hit the sweetspot better!""")
	system.StencilNode(codeWindow)
	yield()
	
	
	system.StartCoding("""Try out the air attack, by pressing K or Numpad 6 in the air!

Once done, click 'continue' below to conclude the tutorial!""", code+codeMove)
	
	yield()
	
	
	system.ShowDialogue("""And there you go! You now know the basics of Castagne!

There is still plenty more to learn and functions to use, you can check the documentations and guides for more!""")
	yield()
	
	system.ShowDialogue("""In general, here are some destinations you'll want to check:
- The website: https://castagneengine.com ; it has the documentation, guides, news, everything you need.
- The discord (link on the site): That's where the community is. Ask for help there, and talk with other enthusiasts!
- Finally, for additional news, you can follow Panthavma, the main developper, either through Twitter or his newsletter.""")
	yield()
	
	system.ShowDialogue("""Don't hesitate to leave some feedback! The engine is still under heavy development.

Have fun making games, see ya!""")
	yield()
	
	
	system.EndTutorial()
