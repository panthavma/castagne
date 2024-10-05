extends "../TutorialBase.gd"


var doGlobalPres = true
var doConfigPres = true
var doCharPres = true

func TutorialScript():
	
	# Global
	system.ShowDialogue("Hello! Welcome to Castagne!\n\nThis tutorial will show you around!")
	
	yield()
	
	if(doGlobalPres):
		system.ShowDialogue("This is the editor's main menu! This is where you can start configuring your game!\n\nLet's see the different options.")
		system.StencilNode(editor.get_node("MainMenu/"))
		
		yield()
		
		system.ShowDialogue("This is where to access the tutorials! There are others, don't hesistate to go here after this tutorial is done!")
		system.StencilNode(editor.get_node("MainMenu/Menu/Tutorials"))
		
		yield()
		
		system.ShowDialogue("""Once you have done that, don't hesitate to review the documentation too! All the info is in there!

This is also available online at https://castagneengine.com""")
		system.StencilNode(editor.get_node("MainMenu/Menu/Documentation"))
		
		yield()
		
		system.ShowDialogue("""To configure some aspects of the game, you might want to open the Castagne Config! We will take a look at it in a few moments!""")
		system.StencilNode(editor.get_node("MainMenu/Menu/Config"))
		
		yield()
		
		system.ShowDialogue("""Castagne is still in development, so you may check here for updates!

There are two branches: Main, which is stable-ish, and Dev, which tends to have a bit more features, but not always super tested or easy to use.

These tutorials will be replaced in a few versions... Hang out with us while you can!""")
		system.StencilNode(editor.get_node("MainMenu/Menu/Updater"))
		
		yield()
		
		system.ShowDialogue("""When you want to make a character, this is where you'll need to look! That's the main part, we will look at it in a few moments!""")
		system.StencilNode(editor.get_node("MainMenu/Menu/CharacterEdit"))
		
		yield()
		
		system.ShowDialogue("""If for any reason the engine crashes when opening a character (might happen, especially if you make your own modules), safe mode is there to save you!""")
		system.StencilNode(editor.get_node("MainMenu/Menu/CharEditOptions/CharacterEditSafe"))
		
		yield()
		
		system.ShowDialogue("""Finally, once you have made some progress on the game, you can start it from this button!""")
		system.StencilNode(editor.get_node("MainMenu/Menu/StartGameModes2/StartGame"))
		
		yield()
	
	
	
	
	
	
	
	
	
	
	# Config
	
	if(doConfigPres):
		system.ShowDialogue("""Alright, that was a few options, let's now look at the config menu!""")
		system.StencilNode(editor.get_node("MainMenu/Menu/Config/Config"))
		
		yield()
		
		editor.EnterConfig()
		system.ShowDialogue("""Here is the config menu! This is where you can change settings for Castagne. It's a bit complex, we'll only take a brief look for now.""")
		system.StencilNode(editor.get_node("Config"))
		
		yield()
		
		system.ShowDialogue("""First of all, remember most important parts of Castagne will have a Documentation button!
This can answer all questions like "What does this option do?", so don't hesitate to check it!""")
		system.StencilNode(editor.get_node("Config/Docs"))
		
		yield()
		
		system.ShowDialogue("""Castagne works with modules, and each one has its page and parameters! Don't hesitate to familiarize yourself with them.

The main way you'll change modules is through choosing a genre, so don't worry too much about it!""")
		system.StencilNode(editor.get_node("Config/Tabs"))
		
		yield()
		
		system.ShowDialogue("""Modules have various parameters available, you can change them individually. Hover on one to get its description!

In any case, if you want to go back to the original value, press the reset button!""")
		system.StencilNode(editor.get_node("Config/Tabs/Core/CategoryList/Game Configuration/ParamList/GameTitle"))
		
		yield()
		
		system.ShowDialogue("""Some parameters may also get their own window! You can access these through big buttons.

Castagne will ask you what kind of game you want to make when we go back, but these tutorials will use a 2.5D fighter!
The same concepts apply regardless.""")
		system.StencilNode(editor.get_node("Config/Tabs/Core/CategoryList/Game Configuration/ParamList/Genre Select"))
		
		yield()
		
		system.ShowDialogue("""Finally, when you are done, don't forget to save! We'll go back to the main menu now.""")
		system.StencilNode(editor.get_node("Config/Save"))
		
		yield()
		
	
	
	
	
	
	
	if(doCharPres):
		editor.EnterMenu()
		system.ShowDialogue("""Now let's see how we will make a character!
		
		You usually will create a new character with the button, but I went ahead and did it for you! So let's open it!""")
		system.StencilNode(editor.get_node("MainMenu/Menu/CharEditOptions/CharacterEditNew"))
		
		yield()
		
		editor._on_CharacterEdit_pressed()
		system.ShowDialogue("""Alright, this is the Castagne Character Editor, the keystone of the engine! Let's take a look at this beauty!""")
		
		yield()
		
		system.ShowDialogue("""This is the game window! It will allow you to play the game and test out your changes!""")
		system.StencilNode(editor.get_node("CharacterEdit/EngineVP"))
		
		yield()
		
		
		
		
		system.ShowTopDialogue("""This part below it is the flow control panel! You can handle how the game runs a bit more from here.
	
At first I put a joke here that you couldn't see it because it was behind the dialog box, but I actually coded the ability to move it in the meantime lol""")
		system.StencilNode(editor.get_node("CharacterEdit/BottomPanel/BMiniPanel"))
		yield()
		
		system.ShowTopDialogue("""These buttons right here allow you to handle how the game is running! If you unpress both, it stops.
	
	You can make it go slowly (33% speed) or advance frame by frame.""")
		system.StencilNode(editor.get_node("CharacterEdit/BottomPanel/BMiniPanel/HBox/Middle/TopBar/Flow"))
		
		yield()
		
		system.ShowTopDialogue("""These allow you control the reset! The main thing you'll want to use it for is to start with a move already executed!

When you want to reset, press 'Training Mode' again!""")
		system.StencilNode(editor.get_node("CharacterEdit/BottomPanel/BMiniPanel/HBox/Match"))
		
		yield()
		
		system.ShowTopDialogue("""This is the console, where your errors and logs appear. You may double click on an error to get to it!""")
		system.StencilNode(editor.get_node("CharacterEdit/BottomPanel/BMiniPanel/HBox/Middle/MiniTool"))
		
		yield()
		
		system.ShowTopDialogue("""And finally, just here, you'll find the reload button! This will apply the changes you'll make soon enough.

Ctrl+R also reloads the engine! It will remember the reset parameters too.""")
		system.StencilNode(editor.get_node("CharacterEdit/BottomPanel/BMiniPanel/HBox/Reload"))
		
		yield()
		
		
		
		
		
		system.ShowDialogue("""This is the other important window: the Code Panel! This is where you'll program the character, which we will see in another tutorial!

Castagne uses a custom script language called Castagne Script! This ensures moves are fast to write, and work online with no changes.""")
		system.StencilNode(editor.get_node("CharacterEdit/CodePanel/Code"))
		
		yield()
		
		system.ShowDialogue("""This might sound intimidating, but we have a few tools! One you might want to check out is the custom editors, which allow you to change values without coding.

They can be activated through this button! Not all states will be able to make custom editors though.

This is very much a work in progress and team oriented feature for now, but you might already get some mileage out of it!""")
		system.StencilNode(editor.get_node("CharacterEdit/CodePanel/UseCustomEditor"))
		
		yield()
		
		system.ShowTopDialogue("""For when you start coding, this small window will help you quite a bit! It shows the documentation of the currently highlighted function, as well as its parameters!

This will help you understand what's going on when reading code!""")
		system.StencilNode(editor.get_node("CharacterEdit/CodePanel/Documentation/Doc"))
		
		yield()
		
		system.ShowTopDialogue("""As usual, you have the documentation button to learn more! It does contain the whole list of functions, and guides!""")
		system.StencilNode(editor.get_node("CharacterEdit/CodePanel/Documentation/FuncdocButton"))
		
		yield()
		
		system.ShowDialogue("""When coding, the editor will try to help you make good code! This will be through these warnings.

It is recommended to follow them! They exist to catch potential mistakes before they happen.""")
		system.StencilNode(editor.get_node("CharacterEdit/CodePanel/Warnings"))
		
		yield()
		
		
		
		system.ShowDialogue("""Now let's look at one last part: the navigation panel! This is where you'll select the correct files and scripts.

Every move in Castagne is a State Script, which gets executed every frame! Coding those scripts will in turn create your character!""")
		system.StencilNode(editor.get_node("CharacterEdit/CodePanel/Header"))
		
		yield()
		
		system.ShowDialogue("""This button here will open the file select! A Castagne file will open up more files itself to have common behavior, and the sum of these files will be your character!

Most of these will be locked by default, you'll want to check those out later, when working on system mechanics!""")
		system.StencilNode(editor.get_node("CharacterEdit/CodePanel/Header/File"))
		
		yield()
		
		editor.get_node("CharacterEdit").On_Header_State_Pressed()
		
		system.ShowTopDialogue("""This is the navigation panel! You may select the state scripts from here!""")
		system.StencilNode(editor.get_node("CharacterEdit/CodePanel/Navigation"))
		
		yield()
		
		system.ShowDialogue("""The main part of the window is here! That's where your states are located. Double clicking one will open it!

When selected, a state will show a few more details, like what it does, and if you can override it! More on that later.""")
		system.StencilNode(editor.get_node("CharacterEdit/CodePanel/Navigation/ChooseState/StateList"))
		
		yield()
		
		system.ShowTopDialogue("""You can also find that information in a longer form down below! All the base files are documented, so this will help you quite a bit!""")
		system.StencilNode(editor.get_node("CharacterEdit/CodePanel/Navigation/ChooseState/StateInfo"))
		
		yield()
		
		system.ShowDialogue("""Then, we have the menu! You can do a few things from there.""")
		system.StencilNode(editor.get_node("CharacterEdit/CodePanel/Navigation/ChooseState/MenuScroll/Menu"))
		
		yield()
		
		system.ShowDialogue("""These buttons can help you manipulate states!

New state and new entity will open a small menu to help you get started with some templates!""")
		system.StencilNode(editor.get_node("CharacterEdit/CodePanel/Navigation/ChooseState/MenuScroll/Menu/NewState"))
		
		yield()
		
		system.ShowDialogue("""These toggles can bring more states to the forefront, even from other files!

This one in particular will show the overridable states! These are super useful as it will allow you to customize a lot of how the engine works quickly!""")
		system.StencilNode(editor.get_node("CharacterEdit/CodePanel/Navigation/ChooseState/MenuScroll/Menu/ToggleOverridableStates"))
		
		yield()
		
		system.ShowDialogue("""And finally, you may here use the state flags to find states quickly!

These are added automatically to states based on their contents, and displayed as icons near their name. This is really useful to find the important parts quickly!""")
		system.StencilNode(editor.get_node("CharacterEdit/CodePanel/Navigation/ChooseState/MenuScroll/Menu/Flags"))
		
		yield()
		
		system.ShowDialogue("""And there we are! The whole editor! You may learn more about it through the other tutorials, but I hope it's more clear already!""")
		
		yield()
		
		system.ShowDialogue("""One final thing: during tutorials you will find this button on top of the screen which opens a menu during the practical parts!
From there you can continue the tutorial, reset the file, or quit.""")
		system.StencilNode(editor.get_node("CharacterEdit/TopBar/HBoxContainer/TutorialWindow"))
		
		yield()
	
	
	
	
	
	
	
	
	
	editor.EnterMenu()
	system.ShowDialogue("""Alright! That was the Castagne presentation!

If this was your first time starting the engine, you'll be whisked back to complete the setup by choosing a genre!""")
	
	yield()
	
	system.ShowDialogue("""Don't forget you can always see this tutorial again by clicking on this button!

There are other tutorials too! I think it's a good idea to do some of them!

Updates will add new tutorials to go along with the features! The tutorials are scheduled to be reworked later, so please give feedback!""")
	system.StencilNode(editor.get_node("MainMenu/Menu/Tutorials"))
	
	yield()
	
	system.ShowDialogue("""Okay that's it for me! Thanks a lot for downloading and trying out Castagne! I hope you have fun with it!

Join the Discord at [ https://discord.gg/CWjWfC9K9T ] (link on the site)! Don't hesitate to tell me what you think or ask questions!'""")
	
	yield()
	
	system.EndTutorial()
