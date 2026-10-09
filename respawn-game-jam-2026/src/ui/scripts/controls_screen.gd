class_name ControlsScreen
extends Control
## Page that lists what each key and controller button does, with a way back.
## Used on its own from the title screen, and laid over the pause menu. Works with the mouse, the keyboard, and a controller.

## Emitted when the player leaves the page while it is laid over another menu.
signal closed

## Scene loaded when the player leaves the page; leave empty when the page is laid over another menu, which it then hands back to.
@export_file("*.tscn") var main_menu_scene: String = ""

@onready var _back_button: Button = $BackButton


## Wires up the button; on its own the page shows at once, and over another menu it waits to be opened.
func _ready() -> void:
	_back_button.pressed.connect(_on_back_button_pressed)
	_back_button.mouse_entered.connect(_back_button.grab_focus)
	if main_menu_scene.is_empty():
		hide()
	else:
		# A controller or keyboard can only press a button that has focus.
		_back_button.grab_focus()


## Goes back on Esc or the B button of a controller as well, the usual ways out of a page.
func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_button_pressed()


## Shows the page over the menu it belongs to, with the back button selected.
func open() -> void:
	show()
	_back_button.grab_focus()


## Leaves the page: back to the title screen, or back to the menu underneath.
func _on_back_button_pressed() -> void:
	if main_menu_scene.is_empty():
		hide()
		closed.emit()
	else:
		get_tree().change_scene_to_file(main_menu_scene)
