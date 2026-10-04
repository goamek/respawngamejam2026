class_name MainMenu
extends Control
## Start screen with buttons to begin a run, see the controls or the credits, or quit.
## Works with the mouse, the keyboard, and a controller.

## Level loaded when the player starts the game.
@export_file("*.tscn") var game_scene: String = ""

@onready var _start_button: Button = $Buttons/StartButton
@onready var _controls_button: Button = $Buttons/ControlsButton
@onready var _credits_button: Button = $Buttons/CreditsButton
@onready var _quit_button: Button = $Buttons/QuitButton


## Frees the mouse, wires up the buttons, and highlights the first one.
func _ready() -> void:
	assert(not game_scene.is_empty(), "MainMenu needs a game scene.")
	# The player captures the mouse while playing, so it arrives here still hidden after a game over.
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_start_button.pressed.connect(_on_start_pressed)
	_controls_button.pressed.connect(_on_controls_pressed)
	_credits_button.pressed.connect(_on_credits_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	for button: Button in [_start_button, _controls_button, _credits_button, _quit_button]:
		# Hovering moves the highlight too, so the mouse and the controller never mark different buttons.
		button.mouse_entered.connect(button.grab_focus)
	# A controller or keyboard can only press a button that has focus.
	_start_button.grab_focus()


## Begins a fresh run in the game scene.
func _on_start_pressed() -> void:
	GameSession.start_new_game()
	get_tree().change_scene_to_file(game_scene)


## Will show the controls.
func _on_controls_pressed() -> void:
	# STUB: does nothing until a controls screen exists
	pass


## Will show the credits.
func _on_credits_pressed() -> void:
	# STUB: does nothing until a credits screen exists
	pass


## Closes the game.
func _on_quit_pressed() -> void:
	get_tree().quit()
