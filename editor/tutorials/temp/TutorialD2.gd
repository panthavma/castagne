extends "../TutorialBase.gd"

# New character + basic setup

func TutorialScript():
	charEditor = editor.get_node("CharacterEdit")
	var charSet = editor.get_node("CharacterSet")
	
	var navigationPanel = charEditor.get_node("CodePanel/Navigation")
	
	system.ShowDialogue("Hello, and welcome to the 'New Character' tutorial! We will learn how to add a new character and set up its basics.")
	
	yield()
	
	system.ShowDialogue("To create a new character, we will start by pressing 'New Character', then select where we want to put it.")
	system.StencilNode(editor.get_node("MainMenu/Menu/CharEditOptions/CharacterEditNew"))
	yield()
	
	system.ShowDialogue("""Then, you enter your file ending in '.casp'. If it already exists, you will add it to the list (it says 'overwriting' because I havent got deeper in how to remove the prompt, but it won't destroy any files).
You can't create files inside the Castagne folder, but you can add files from it.""")
	system.StencilNode(editor.get_node("MainMenu/Menu/CharEditOptions/CharacterEditNew"))
	yield()
	
	editor.EnterSubmenu("CharacterSet")
	charSet._on_NewCharDialog_file_selected("user://tutorial/TutorialD2Char.casp")
	system.ShowDialogue("""From there, you can select an existing Castagneur to get started quickly! The Castagneurs are Castagne's 'official' base characters, which you can use as a base. They have their base setup already done, so you can get started quickly!

For these tutorials, we will use Baston as a base, so let's just select him here.""")
	system.StencilNode(editor.get_node("CharacterAddNew"))
	yield()
	
	editor.get_node("CharacterAddNew")._on_OK_pressed()
	system.ShowTopDialogue("""Now we are back sent to the Character Setup screen. You can see that our character is now here in the list!""")
	system.ContinueNextFrame()
	yield()
	system.StencilNode(charSet.get_node("LeftPanel/CharacterList"))
	yield()
	
	system.ShowTopDialogue("""Let's save our changes by clicking on confirm.""")
	system.StencilNode(charSet.get_node("LeftPanel/WindowControls/Confirm"))
	yield()
	
	system.PressButton(charSet.get_node("LeftPanel/WindowControls/Confirm"))
	system.ContinueNextFrame()
	yield()
	system.ContinueNextFrame()
	yield()
	system.ContinueNextFrame()
	yield()
	
	#var characterChoiceButton = editor.get_node("MainMenu/FlowPanel/Custom/VBox").get_child(0).get_child(2).get_child(0).get_child(1)
	#characterChoiceButton.select(characterChoiceButton.get_item_count() -1)
	system.ShowDialogue("""Back on the main menu! We now want to change the character to our new one, then open the character editor.""")
	#system.StencilNode(characterChoiceButton)
	system.StencilNode(editor.get_node("MainMenu/FlowPanel/Custom"))
	yield()
	
	var battleInitData = editor.configData.GetBaseBattleInitData()
	battleInitData["players"][1]["entities"][1]["scriptpath"] = "user://tutorial/TutorialD2Char.casp"
	battleInitData["players"][1]["inputdevice"] = "k1"
	editor.StartCharacterEditor(false, battleInitData)
	system.ContinueNextFrame()
	yield()
	
	var codeWindow = editor.get_node("CharacterEdit/CodePanel/Code")
	var headerStateButton = editor.get_node("CharacterEdit/CodePanel/Header/State")
	system.ShowDialogue("""Now that we're in let's get started! To make moves we have to use Castagne Script (CASP for short)! It's a custom language made for efficient move creation.

It might sound intimidating, but it's quite easy in practice you'll see!""")
	system.StencilNode(codeWindow)
	yield()
	
	system.ShowDialogue("""We're gonna do that step by step over a few tutorials, and introduce the parts as they come. Castagne characters work using 'States', which can be 'Standing', 'Attacking', 'Being Hit', etc. These States' behavior is given by a 'State Script'.

You can select the State Script to edit using that button, you can see we are on the 'Character' script.""")
	system.StencilNode(headerStateButton)
	yield()
	
	system.ShowDialogue("""The Character script is a bit special, it holds some general values about the character itself, which can be read from outside the game. Think the name of the character, or the position in the Character Select Screen.""")
	system.StencilNode(codeWindow)
	yield()
	
	var codeCharacter = charEditor.get_node("CodePanel/Code").get_text() + "\n\nName: Baston Jr.\nEditorName: My First Character\n"
	
	charEditor.get_node("CodePanel/Code").set_text(codeCharacter)
	system.ShowDialogue("""You can add values by putting Name: Value

Here I added two: Name, and EditorName. Name is the one displayed to players, while EditorName is for what you see in the editor menu!""")
	system.StencilNode(codeWindow)
	yield()
	
	system.ShowDialogue("""You can also see lines that start with '#'. Those are comments, and ignored by the engine when compiling, so we'll use them for annotations.""")
	system.StencilNode(codeWindow)
	yield()
	
	system.ShowDialogue("""You can also see a Skeleton property! This allows us to load another file before this one. This is very useful for system mechanics! Here it's used to setup the graphics of Baston.""")
	system.StencilNode(codeWindow)
	yield()
	
	system.ShowDialogue("""Castagne also loads its own skeleton, which manages even the most basic stuff like Hitstun. This means you can overwrite it if needed!
This is one of the main elements of Castagne's design: you can overwrite even parts that are part of the core, and because it's in CASP, it will work online directly!""")
	system.StencilNode(codeWindow)
	yield()
	
	system.ShowDialogue("""Now, before continuing, let's play a little bit with the character! You can use the WASD / Arrow keys to move. (You are locked to default keyboard controls for the tutorial)

When you are done, click on the top button there! It will be used for the next steps too.""")
	system.StencilNode(charEditor.get_node("TopBar/HBoxContainer/TutorialWindow"))
	yield()
	
	codeCharacter = ":Character:\n"+codeCharacter
	var codeVariables = ":Variables:\n## This is the Variables block, where you can store custom variables or overwrite defined ones.You can see all available default variables by activating 'Show All Variables' in the navigation panel.\n"
	
	var code = codeCharacter + "\n"+codeVariables
	
	system.StartCoding("""Play a bit with the character, and continue when you feel to!

Press WASD or the Arrow keys to move.""", code)
	
	yield()
	
	
	system.ShowDialogue("""From there on, you can start creating your moveset! But before that, we'll see how to change a character's physics and movement.
See you next tutorial!""")
	yield()
	
	
	system.EndTutorial()
	return
	
	
	
	system.ShowDialogue("""Welcome back! Now we will start modifying some Variables! Let's go to the :Variables: script!

First, we will click on the State Script button to open the Navigation panel.""")
	system.StencilNode(headerStateButton)
	yield()
	
	charEditor.On_Header_State_Pressed()
	system.ShowDialogue("""Now lets double click the Variables state script to load it! You can also press 'Open State'.""")
	system.StencilNode(charEditor.get_node("CodePanel/Navigation"))
	yield()
	
	
	navigationPanel.hide()
	charEditor.ChangeCodePanelState("Variables")
	system.ShowDialogue("""The variables block is also a special state script, in that it will only hold variable declarations. Variables are values we can set by name, thus allowing us to change them easily and adapt in all places.

As opposed to Character, these are gameplay values, like walk speed.""")
	system.StencilNode(codeWindow)
	yield()
	
	system.ShowDialogue("""In fact, let's do that right now! A variable declaration is made of a few parts. Let's see them one by one.""")
	system.StencilNode(codeWindow)
	yield()
	
	codeVariables = codeWindow.get_text()
	codeVariables += "\n\ndef"
	codeWindow.set_text(codeVariables)
	system.ShowDialogue("""First is the mutability, which is how the variable changes.
- 'def': Constants, useful for balancing values. The one you'll use most.
- 'var': Variables, which can change during gameplay. For when you're doing more advanced behaviors.
- 'internal': To access internal engine values, when you are doing REALLY advanced behavior""")
	system.StencilNode(codeWindow)
	yield()
	
	codeVariables = codeWindow.get_text()
	codeVariables += " MOVE_Walk_SpeedF"
	codeWindow.set_text(codeVariables)
	system.ShowDialogue("""We'll use def here since we're altering balance values.

Then is the name. Here we'll use 'MOVE_Walk_SpeedF', so that the engine recognizes it.""")
	system.StencilNode(codeWindow)
	yield()
	
	codeVariables = codeWindow.get_text()
	codeVariables += " int()"
	codeWindow.set_text(codeVariables)
	system.ShowDialogue("""Then is the type, along with some parenthesis (which will hold additional info in the future). Here are some of them:
- 'int': Numbers
- 'str': String of characters.
Here it's int because it's a number.""")
	system.StencilNode(codeWindow)
	yield()
	
	codeVariables = codeWindow.get_text()
	codeVariables += " = 5000\n"
	codeWindow.set_text(codeVariables)
	system.ShowDialogue("""Finally, the value! Here I'll put a big number, 5000, so that we go fast. Try it out for yourself then let's continue!""")
	system.StencilNode(codeWindow)
	yield()
	
	system.StartCoding("""Move forward at different speeds!  WASD or arrow keys to move, and change the number value on the variable to play with it!""",
	codeCharacter+" \n:Variables:\n"+codeVariables)
	yield()
	
	
	
	
	
	
	
	
	
	
	
	
	system.ShowDialogue("""As you can see, we go quite fast. We need the name to be exactly correct, so that we can override one of the already declared variables. But how can we do so?
	
	Let me show you an easy way. Open the navigation panel.""")
	system.StencilNode(headerStateButton)
	yield()
	
	var showAllVariables = navigationPanel.get_node("ChooseState/Menu/ToggleShowVariables")
	charEditor.On_Header_State_Pressed()
	system.ShowDialogue("""Then, check this checkbox: 'Show All Variables'. This will show all the Variables blocks from the previous files. They all start with 'Variables-'.""")
	system.StencilNode(showAllVariables)
	yield()
	
	showAllVariables.set_pressed_no_signal(true)
	showAllVariables.emit_signal("pressed")
	system.ShowDialogue("""Then, we'll choose this one: 'Variables-Physics-Base'. SINGLE click it, as double click will open it up.""")
	system.StencilNode(navigationPanel)
	yield()
	
	system.ShowDialogue("""Instead, click 'Override State'. This will create a new state with that same name, from which we will set up our variables.""")
	system.StencilNode(navigationPanel.get_node("ChooseState/Menu/OverrideState"))
	yield()
	
	navigationPanel.hide()
	var customEditorButton = charEditor.get_node("CodePanel/UseCustomEditor")
	system.SetCode(codeCharacter + "\n:Variables:\n" +codeVariables+"\n:Variables-Physics-Base:\n# Overriden\n")
	charEditor.ReloadEngine()
	charEditor.ChangeCodePanelState("Variables-Physics-Base")
	system.ShowDialogue("""Now the state is empty. We will use an additional tool: Custom Editors.

Castagne can generate a small editor from your code to help you alter parts. It's meant as a helper for teams and designers, and we'll use it here by clicking the 'Show Custom Editor' button.""")
	system.StencilNode(customEditorButton)
	yield()
	
	showAllVariables.set_pressed_no_signal(true)
	customEditorButton.set_pressed_no_signal(true)
	customEditorButton.emit_signal("pressed")
	system.ShowDialogue("""You can now see the variables available! Click on the override button to bring it to the current state.""")
	system.StencilNode(charEditor.get_node("CodePanel/CustomEditor"))
	yield()
	
	system.SetCode(codeCharacter + "\n:Variables:\n" +codeVariables+"\n:Variables-Physics-Base:\n# Overriden\ndef MOVE_Walk_SpeedB int() = -5000\n")
	charEditor.ReloadEngine()
	system.ShowDialogue("""Now you can alter it! We can put a big value again, like -5000. Try it! I'll also bring the other variable here for easier edition.

Play a bit with the values, and then we'll finish!""")
	system.StencilNode(charEditor.get_node("CodePanel/CustomEditor"))
	yield()
	
	system.StartCoding("""Play with the walking speed! WASD or arrow keys to move.

You can bring more variables in! Always remember you can reset the code if you get stuck. Continue to end the tutorial!""",
	codeCharacter+"\n:Variables-Physics-Base:\ndef MOVE_Walk_SpeedF int() = 5000\ndef MOVE_Walk_SpeedB int() = -5000\n")
	yield()
	
	system.ShowDialogue("""And there you go, you got half of Castagne's basics! Good job!

In the next tutorial, we will make some actual attacks!""")
	yield()
	
	system.EndTutorial()
