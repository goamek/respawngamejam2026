class_name MainMenu
extends Control
## Start screen with buttons to begin a run, see the controls or the credits, or quit.
## Works with the mouse, the keyboard, and a controller.

## Level loaded when the player starts the game.
@export_file("*.tscn") var game_scene: String = ""
## Page that lists the controls.
@export_file("*.tscn") var controls_scene: String = ""
## Page that lists who made the game.
@export_file("*.tscn") var credits_scene: String = ""

@onready var _start_button: Button = $Buttons/StartButton
@onready var _controls_button: Button = $Buttons/ControlsButton
@onready var _credits_button: Button = $Buttons/CreditsButton
@onready var _quit_button: Button = $Buttons/QuitButton


## Frees the mouse, starts loading the game scene in the background, wires up the buttons, and highlights the first one.
func _ready() -> void:
	assert(not game_scene.is_empty(), "MainMenu needs a game scene.")
	assert(not controls_scene.is_empty(), "MainMenu needs a controls scene.")
	assert(not credits_scene.is_empty(), "MainMenu needs a credits scene.")
	# The player captures the mouse while playing, so it arrives here still hidden after a game over.
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# Loaded while the player reads the menu, so pressing Start does not have to wait for it.
	SceneTransition.prepare(game_scene)
	_start_button.pressed.connect(_on_start_button_pressed)
	_controls_button.pressed.connect(_on_controls_button_pressed)
	_credits_button.pressed.connect(_on_credits_button_pressed)
	_quit_button.pressed.connect(_on_quit_button_pressed)
	for button: Button in [_start_button, _controls_button, _credits_button, _quit_button]:
		# Hovering moves the highlight too, so the mouse and the controller never mark different buttons.
		button.mouse_entered.connect(button.grab_focus)
	# A controller or keyboard can only press a button that has focus.
	_start_button.grab_focus()


## Begins a fresh run in the game scene, behind a fade.
func _on_start_button_pressed() -> void:
	if SceneTransition.is_changing:
		return
	GameSession.start_new_game()
	SceneTransition.change_to(game_scene)


## Shows the controls page.
func _on_controls_button_pressed() -> void:
	get_tree().change_scene_to_file(controls_scene)


## Shows the credits page.
func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file(credits_scene)


## Closes the game.
func _on_quit_button_pressed() -> void:
	get_tree().quit()
