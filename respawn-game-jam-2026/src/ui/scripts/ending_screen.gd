class_name EndingScreen
extends Control
## Card shown when a run is over: a title and a few lines for whichever ending was reached, and a way back to the menu.
## Works with the mouse, the keyboard, and a controller.

## Heading shown for each ending.
const TITLES: Dictionary[int, String] = {
	GameSession.Ending.ESCAPE: "Escaped",
	GameSession.Ending.UNCOVERED: "Uncovered",
	GameSession.Ending.CAUGHT: "Caught",
}
## Story text shown for each ending.
const STORIES: Dictionary[int, String] = {
	GameSession.Ending.ESCAPE: "You step through the white door with the coloring book under your arm.\n\nBehind you the school goes grey. It is still in there.\n\nYou got out, but you never faced it.",
	GameSession.Ending.UNCOVERED: "Under the white light the black scribble flakes away, and the colors you first drew show through.\n\nIt was never a monster. It was only a drawing you were scared of.",
	GameSession.Ending.CAUGHT: "A new drawing appears on the art studio wall.\n\nA child, labeled \"ME\", scribbled over in black.",
}

## Scene loaded when the player leaves the card.
@export_file("*.tscn") var main_menu_scene: String = ""
## Picture for the Escape ending; leave empty to show text only.
@export var escape_picture: Texture2D
## Picture for the Uncovered ending; leave empty to show text only.
@export var uncovered_picture: Texture2D
## Picture for the Caught ending; leave empty to show text only.
@export var caught_picture: Texture2D

@onready var _picture: TextureRect = $Card/Picture
@onready var _title: Label = $Card/Title
@onready var _story: Label = $Card/Story
@onready var _menu_button: Button = $Card/MenuButton


## Frees the mouse, fills in the card for the ending that was reached, and highlights the button.
func _ready() -> void:
	assert(not main_menu_scene.is_empty(), "EndingScreen needs a main menu scene.")
	# The player captures the mouse while playing, so it arrives here still hidden.
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var ending: GameSession.Ending = GameSession.ending
	_title.text = TITLES[ending]
	_story.text = STORIES[ending]
	_picture.texture = _picture_for(ending)
	_picture.visible = _picture.texture != null
	_menu_button.pressed.connect(_on_menu_button_pressed)
	_menu_button.mouse_entered.connect(_menu_button.grab_focus)
	# A controller or keyboard can only press a button that has focus.
	_menu_button.grab_focus()


## Returns the picture set for [param ending], or null when there is none.
func _picture_for(ending: GameSession.Ending) -> Texture2D:
	match ending:
		GameSession.Ending.ESCAPE:
			return escape_picture
		GameSession.Ending.UNCOVERED:
			return uncovered_picture
		_:
			return caught_picture


## Goes back to the main menu with a fresh run ready.
func _on_menu_button_pressed() -> void:
	GameSession.start_new_game()
	get_tree().change_scene_to_file(main_menu_scene)
