class_name PauseMenu
extends Control
## Menu that freezes the game while it is open: a master volume slider and a button back to the title screen.
## The pause action opens and closes it. It works with the mouse, the keyboard, and a controller.

## Color of a control's text while it is not the one selected.
const IDLE_COLOR: Color = Color(0.5, 0.5, 0.5)
## Color of a control's text while it is the one selected.
const FOCUS_COLOR: Color = Color.WHITE

## Player whose game this pauses; the menu stays shut while their controls are taken away, as when caught.
@export var player: Player
## Scene the quit button loads, normally the title screen.
@export_file("*.tscn") var main_menu_scene: String = ""

@onready var _volume_label: Label = $Panel/Items/VolumeRow/VolumeLabel
@onready var _volume_slider: HSlider = $Panel/Items/VolumeRow/VolumeSlider
@onready var _quit_button: Button = $Panel/Items/QuitButton


## Starts closed, and wires up the slider and the button.
func _ready() -> void:
	hide()
	_volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	_volume_slider.focus_entered.connect(_on_volume_slider_focus_entered)
	_volume_slider.focus_exited.connect(_on_volume_slider_focus_exited)
	_volume_slider.mouse_entered.connect(_volume_slider.grab_focus)
	_quit_button.pressed.connect(_on_quit_button_pressed)
	_quit_button.mouse_entered.connect(_quit_button.grab_focus)


## Opens or closes the menu on the pause action.
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return
	get_viewport().set_input_as_handled()
	if visible:
		close()
	elif player.is_input_enabled:
		open()


## Freezes the game, frees the mouse, and shows the menu with the volume slider selected.
func open() -> void:
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_volume_slider.set_value_no_signal(AudioController.get_volume(AudioController.Bus.MASTER))
	show()
	_volume_slider.grab_focus()


## Hides the menu, captures the mouse again, and lets the game carry on.
func close() -> void:
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false


## Sets the master volume to the slider's new [param value], from 0 to 1.
func _on_volume_slider_value_changed(value: float) -> void:
	AudioController.set_volume(AudioController.Bus.MASTER, value)


## Brightens the slider's label while the slider is selected.
func _on_volume_slider_focus_entered() -> void:
	_volume_label.add_theme_color_override("font_color", FOCUS_COLOR)


## Dims the slider's label once the slider is no longer selected.
func _on_volume_slider_focus_exited() -> void:
	_volume_label.add_theme_color_override("font_color", IDLE_COLOR)


## Unfreezes the game and leaves for the title screen with a fresh run ready.
func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	GameSession.start_new_game()
	get_tree().change_scene_to_file(main_menu_scene)
