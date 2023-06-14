extends VBoxContainer

var giNameBase
var giNamePress
var giNameRelease

func Setup(gameInputName):
	giNameBase = gameInputName
	giNamePress = giNameBase + "Press"
	giNameRelease = giNameBase + "Release"
	$Direct.set_text(gameInputName)

func Update(inputs):
	$Direct.set_pressed_no_signal(inputs[giNameBase])
	$Derived/Press.set_pressed_no_signal(inputs[giNamePress])
	$Derived/Release.set_pressed_no_signal(inputs[giNameRelease])

func OverrideInputs(inputs):
	inputs[giNameBase] = $Direct.is_pressed()
	$Derived/Press.set_pressed_no_signal(false)
	$Derived/Release.set_pressed_no_signal(false)
