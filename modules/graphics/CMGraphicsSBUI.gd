# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModuleSpecblock.gd"

func SetupSpecblock(_argument):
	SetDisplayName("User Interface")
	SetForMainEntitySubEntity(true, false)
	
	AddDefine("UI_UseWidgets", true, "Use Widgets", {
		"Description": "Global switch to disable all player widgets.",
	})
	
	AddStructure("Widgets", "UI_Widgets_", null, null, {
		"Description": "Holds the data needed to spawn player widgets dynamically.",
	})
	AddStructureDefine("UseWidget", true, "Use Widget", {
		"Description": "Decides if the widget should be created or not. You can disable default widgets by overriding them here.",
	})
	AddStructureDefine("Type", 1, "Widget Type", {
		"Options":["Custom", "Bar", "Icons", "Icon Switch", "Text",],
		"Description": """Type of widget to spawn. All but 'custom' will use a default widget for quick prototyping or simple needs.
- Custom: User-defined widget through the 'Custom Scene Path' value. See documentation for more details.
- Bar: A progress bar that can display up to two values together.
- Icons: A list of icons that dynamically grows according to a value.
- Icon Switch: An icon that changes between set ones based on a value.
- Text: A text label that can be set from a value.
""",
	})
	AddStructureDefine("ScenePath", "res://", "Custom Scene Path")
	AddStructureDefine("HookPoint", "MeterSub", "Hook Point")
	AddStructureDefine("Direction", 1, "Direction", {
		"Options":["Left to Right", "Right to Left", "Down to Up", "Up to Down", "Horizontal Centered", "Vertical Centered"]
	})
	
	AddStructureSeparator()
	
	AddStructureDefine("Variable1", "", "Variable Main")
	AddStructureDefine("Variable2", "", "Variable Sub")
	AddStructureDefine("Variable3", "", "Variable Max")
	
	AddStructureSeparator("Default Widgets Parameters")
	
	AddStructureDefine("Asset1", "", "Asset 1")
	AddStructureDefine("Asset2", "", "Asset 2")
	AddStructureDefine("Asset3", "", "Asset 3")
	
	AddStructureDefine("DefaultColor", 0, "Color", {
		"Options":["White", "Red", "Orange", "Yellow", "Green", "Cyan", "Blue", "Purple", "Pink", "Gray", "Black"]
	})
	
