class_name CreditsScreen
extends Control
## Page that lists who made the game and whose assets it uses, with a way back to the title screen.
## Opened from the title screen, and shown after a winning ending. Works with the mouse, the keyboard, and a controller.

## Scene loaded when the player leaves the page.
@export_file("*.tscn") var main_menu_scene: String = ""
## Time any music still playing takes to fade out when the page is left, in seconds.
@export var music_fade_time: float = 1.0

@onready var _back_button: Button = $BackButton


## Frees the mouse, wires up the button, and highlights it.
func _ready() -> void:
	assert(not main_menu_scene.is_empty(), "CreditsScreen needs a main menu scene.")
	# After an ending the mouse may still be captured from play.
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_back_button.pressed.connect(_on_back_button_pressed)
	_back_button.mouse_entered.connect(_back_button.grab_focus)
	# A controller or keyboard can only press a button that has focus.
	_back_button.grab_focus()


## Goes back on Esc or the B button of a controller as well, the usual ways out of a page.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_button_pressed()


## Fades out the ending music, if this page followed an ending, and returns to the title screen.
func _on_back_button_pressed() -> void:
	AudioController.stop_music(music_fade_time)
	get_tree().change_scene_to_file(main_menu_scene)
