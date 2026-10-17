class_name ObjectivesScreen
extends Control
## Page laid over the pause menu that says what to do next, which colors have been found, and every hint shown so far.
## Fills itself in each time it opens, so it needs no signals from the level. Works with the mouse, the keyboard, and a controller.

## Emitted when the player leaves the page.
signal closed

## Color of the text for a color not found yet, and for the hint list.
const IDLE_COLOR: Color = Color(0.5, 0.5, 0.5)
## Line shown in place of a color that has not been found yet.
const UNKNOWN_TEXT: String = "???"
## Line that counts the colors found; filled in with the count and the total.
const COUNT_TEXT: String = "%d/%d found"
## Mark put in front of each line of the hint list.
const BULLET: String = "• "
## Line shown in the hint list before any hint has appeared.
const NO_HINTS_TEXT: String = "No hints yet"

## Player whose progress and hints the page shows; set by the menu that owns it.
@export var player: Player
## Colors in the order the level hands them out; the goal shown is the one for the first color here not yet found.
@export var route: Array[Spectrum.Hue] = [
	Spectrum.Hue.YELLOW,
	Spectrum.Hue.GREEN,
	Spectrum.Hue.INDIGO,
	Spectrum.Hue.BLUE,
	Spectrum.Hue.RED,
	Spectrum.Hue.ORANGE,
	Spectrum.Hue.VIOLET,
]
## Goal shown while each color is the next one to find.
@export var goals: Dictionary[Spectrum.Hue, String] = {
	Spectrum.Hue.YELLOW: "Find the library",
	Spectrum.Hue.GREEN: "Yellow doors open now. Find the greenhouse",
	Spectrum.Hue.INDIGO: "Yellow doors open now. Find the greenhouse",
	Spectrum.Hue.BLUE: "Green doors open now. Find the gym and the locker room",
	Spectrum.Hue.RED: "Blue doors open now. Find the cafeteria",
	Spectrum.Hue.ORANGE: "Red doors open now. Mix colors in the art studio",
	Spectrum.Hue.VIOLET: "Red doors open now. Mix colors in the art studio",
}
## Room each color is found in; shown beside the color only once it has been found.
@export var rooms: Dictionary[Spectrum.Hue, String] = {
	Spectrum.Hue.YELLOW: "Library",
	Spectrum.Hue.GREEN: "Greenhouse",
	Spectrum.Hue.INDIGO: "Greenhouse",
	Spectrum.Hue.BLUE: "Locker room",
	Spectrum.Hue.RED: "Cafeteria",
	Spectrum.Hue.ORANGE: "Art studio",
	Spectrum.Hue.VIOLET: "Art studio",
}
## Hints left out of the list once the given color has been found, because the puzzle they point to is done.
@export var finished_hints: Dictionary[Spectrum.Hue, PackedStringArray] = {
	Spectrum.Hue.YELLOW: PackedStringArray([
		"Find the library",
		"Scan the bookshelves for a book you can take",
	]),
}
## Goal shown before the player has picked up the flashlight.
@export var no_light_goal: String = "Find a light"
## Goal shown once every color has been found and the light turns white.
@export var white_goal: String = "White doors open now. Escape through the courtyard, or face the drawing"

@onready var _goal: Label = $Card/Goal
@onready var _count: Label = $Card/ColorsHeading/Count
@onready var _colors: GridContainer = $Card/Colors
@onready var _hints: VBoxContainer = $Card/HintScroll/Hints
@onready var _hint_scroll: ScrollContainer = $Card/HintScroll
@onready var _back_button: Button = $BackButton


## Wires up the button and waits to be opened.
func _ready() -> void:
	hide()
	_back_button.pressed.connect(_on_back_button_pressed)
	_back_button.mouse_entered.connect(_back_button.grab_focus)


## Goes back on Esc or the B button of a controller as well, the usual ways out of a page.
func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_button_pressed()


## Fills the page in with the player's progress so far and shows it, with the back button selected.
func open() -> void:
	var found: Array[Spectrum.Hue] = []
	if player.flashlight != null:
		found = player.flashlight.unlocked_hues
	_goal.text = _current_goal(found)
	_fill_colors(found)
	_fill_hints(found)
	show()
	_back_button.grab_focus()


## Returns the goal for the player's progress, given the colors in [param found].
func _current_goal(found: Array[Spectrum.Hue]) -> String:
	if player.flashlight == null:
		return no_light_goal
	for hue: Spectrum.Hue in route:
		if not found.has(hue):
			return goals[hue]
	return white_goal


## Lists every color on the route: in its own color with its room once found, and hidden until then.
func _fill_colors(found: Array[Spectrum.Hue]) -> void:
	for child: Node in _colors.get_children():
		child.free()
	var count: int = 0
	for hue: Spectrum.Hue in route:
		var is_found: bool = found.has(hue)
		if is_found:
			count += 1
		var text_color: Color = Spectrum.color_of(hue) if is_found else IDLE_COLOR
		_add_label(_colors, ("[x] " + _name_of(hue)) if is_found else ("[  ] " + UNKNOWN_TEXT), text_color)
		_add_label(_colors, rooms[hue] if is_found else "", IDLE_COLOR)
	_count.text = COUNT_TEXT % [count, route.size()]


## Lists the hints shown so far, newest first, leaving out those for puzzles done given the colors in [param found], and scrolls back to the top.
func _fill_hints(found: Array[Spectrum.Hue]) -> void:
	for child: Node in _hints.get_children():
		child.free()
	var finished: PackedStringArray = PackedStringArray()
	for hue: Spectrum.Hue in finished_hints:
		if found.has(hue):
			finished.append_array(finished_hints[hue])
	var shown: int = 0
	for index: int in range(player.hint_history.size() - 1, -1, -1):
		var hint: String = player.hint_history[index]
		if not finished.has(hint):
			_add_label(_hints, BULLET + hint, Color.WHITE)
			shown += 1
	if shown == 0:
		_add_label(_hints, NO_HINTS_TEXT, IDLE_COLOR)
	_hint_scroll.scroll_vertical = 0


## Adds a line of [param text] in [param color] to [param parent].
func _add_label(parent: Container, text: String, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override(&"font_color", color)
	label.add_theme_font_size_override(&"font_size", 28)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(label)


## Returns the name of [param hue] as the player reads it, such as "Yellow".
func _name_of(hue: Spectrum.Hue) -> String:
	return Spectrum.Hue.find_key(hue).capitalize()


## Hides the page and hands control back to the menu underneath.
func _on_back_button_pressed() -> void:
	hide()
	closed.emit()
