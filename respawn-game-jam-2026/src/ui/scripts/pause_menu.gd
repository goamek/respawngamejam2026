class_name PauseMenu
extends Control
## Menu that freezes the game while it is open: volume and brightness sliders, the controls page, and a button back to the title screen.
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
@onready var _brightness_label: Label = $Panel/Items/BrightnessRow/BrightnessLabel
@onready var _brightness_slider: HSlider = $Panel/Items/BrightnessRow/BrightnessSlider
@onready var _controls_button: Button = $Panel/Items/ControlsButton
@onready var _quit_button: Button = $Panel/Items/QuitButton
@onready var _panel: Control = $Panel
@onready var _controls: ControlsScreen = $Controls


## Starts closed, wires up the sliders, the buttons and the controls page, and applies the brightness chosen earlier.
func _ready() -> void:
	hide()
	_volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	_brightness_slider.value_changed.connect(_on_brightness_slider_value_changed)
	for row: Array in [[_volume_slider, _volume_label], [_brightness_slider, _brightness_label]]:
		var slider: HSlider = row[0]
		slider.focus_entered.connect(_on_slider_focus_changed.bind(row[1], FOCUS_COLOR))
		slider.focus_exited.connect(_on_slider_focus_changed.bind(row[1], IDLE_COLOR))
		slider.mouse_entered.connect(slider.grab_focus)
	_apply_brightness()
	_controls_button.pressed.connect(_on_controls_button_pressed)
	_controls_button.mouse_entered.connect(_controls_button.grab_focus)
	_controls.closed.connect(_on_controls_closed)
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
	_brightness_slider.set_value_no_signal(GameSession.brightness)
	_controls.hide()
	_panel.show()
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


## Remembers the slider's new [param value] as the brightness and applies it at once, so the change shows behind the menu.
func _on_brightness_slider_value_changed(value: float) -> void:
	GameSession.brightness = value
	_apply_brightness()


## Draws the level's 3D picture at the chosen brightness; the menus and the on-screen display are not affected.
func _apply_brightness() -> void:
	var environment: Environment = get_viewport().find_world_3d().environment
	if environment == null:
		return
	environment.adjustment_enabled = true
	environment.adjustment_brightness = GameSession.brightness


## Gives [param label] the [param color] that shows whether its slider is the one selected.
func _on_slider_focus_changed(label: Label, color: Color) -> void:
	label.add_theme_color_override("font_color", color)


## Swaps the menu for the controls page.
func _on_controls_button_pressed() -> void:
	_panel.hide()
	_controls.open()


## Brings the menu back once the controls page is left, with its button still selected.
func _on_controls_closed() -> void:
	_panel.show()
	_controls_button.grab_focus()


## Unfreezes the game and leaves for the title screen with a fresh run ready.
func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	GameSession.start_new_game()
	get_tree().change_scene_to_file(main_menu_scene)
