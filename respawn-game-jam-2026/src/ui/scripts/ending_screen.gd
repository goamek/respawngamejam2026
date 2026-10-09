class_name EndingScreen
extends Control
## Card shown when a run is over: a title, a few lines and music for whichever ending was reached, and a way on to the credits or back to the menu.
## Works with the mouse, the keyboard, and a controller.

## Heading shown for each ending.
const TITLES: Dictionary[int, String] = {
	GameSession.Ending.ESCAPE: "Escaped",
	GameSession.Ending.UNCOVERED: "Uncovered",
	GameSession.Ending.CAUGHT: "Caught",
}
## Story text shown for each ending.
const STORIES: Dictionary[int, String] = {
	GameSession.Ending.ESCAPE: "You step through the white door.\n\nYou got out, but you never faced it.",
	GameSession.Ending.UNCOVERED: "Under the white light the black scribble flakes away, and the colors you first drew show through.\n\nIt was never a monster. It was only a drawing you were scared of.",
	GameSession.Ending.CAUGHT: "A new drawing appears on the art studio wall.\n\nA child, scribbled over in black.",
}
## Name in the sound library of the music played for each ending: one track for both ways of winning, another for losing.
const MUSIC: Dictionary[int, StringName] = {
	GameSession.Ending.ESCAPE: &"ending_win",
	GameSession.Ending.UNCOVERED: &"ending_win",
	GameSession.Ending.CAUGHT: &"ending_lose",
}
## How loud the music for each ending plays, from 0 for silent to 1 for as recorded.
const MUSIC_VOLUMES: Dictionary[int, float] = {
	GameSession.Ending.ESCAPE: 0.33,
	GameSession.Ending.UNCOVERED: 0.33,
	GameSession.Ending.CAUGHT: 1.0,
}

## Line that tells the player how many of the winning endings they have found; filled in with the count and the total.
const PROGRESS_TEXT: String = "%d/%d endings complete"
## Words on the button when it leads on to the credits.
const CONTINUE_LABEL: String = "Continue"

## Scene loaded when the player leaves the card after losing.
@export_file("*.tscn") var main_menu_scene: String = ""
## Scene loaded when the player leaves the card after winning; leave empty to go to the main menu then too.
@export_file("*.tscn") var credits_scene: String = ""
## Time the card takes to fade in out of the black, in seconds.
@export var fade_in_time: float = 1.2
## Time the ending music takes to fade in if it is not already playing, and to fade out when the card is left, in seconds.
@export var music_fade_time: float = 1.0
## Picture for the Escape ending; leave empty to show text only.
@export var escape_picture: Texture2D
## Picture for the Uncovered ending; leave empty to show text only.
@export var uncovered_picture: Texture2D
## Picture for the Caught ending; leave empty to show text only.
@export var caught_picture: Texture2D

@onready var _card: Control = $Card
@onready var _picture: TextureRect = $Card/Picture
@onready var _title: Label = $Card/Title
@onready var _story: Label = $Card/Story
@onready var _progress: Label = $Card/Progress
@onready var _menu_button: Button = $Card/MenuButton


## Frees the mouse, fills in the card for the ending that was reached, counts it, starts its music, highlights the button, and fades the card in.
func _ready() -> void:
	assert(not main_menu_scene.is_empty(), "EndingScreen needs a main menu scene.")
	# The player captures the mouse while playing, so it arrives here still hidden.
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var ending: GameSession.Ending = GameSession.ending
	_title.text = TITLES[ending]
	_story.text = STORIES[ending]
	_picture.texture = _picture_for(ending)
	_picture.visible = _picture.texture != null
	GameSession.record_ending(ending)
	# Being caught is not one of the endings to find, so that card says nothing about them.
	_progress.visible = ending != GameSession.Ending.CAUGHT
	_progress.text = PROGRESS_TEXT % [GameSession.endings_found(), GameSession.WINNING_ENDING_COUNT]
	# Usually a no-op: the level starts this music as its ending begins, and it carries on across the scene change.
	play_music_for(ending, music_fade_time)
	if _leads_to_credits():
		_menu_button.text = CONTINUE_LABEL
	_menu_button.pressed.connect(_on_menu_button_pressed)
	_menu_button.mouse_entered.connect(_menu_button.grab_focus)
	# A controller or keyboard can only press a button that has focus.
	_menu_button.grab_focus()
	_card.modulate.a = 0.0
	create_tween().tween_property(_card, "modulate:a", 1.0, fade_in_time)


## Fades in the music for [param ending] over [param fade_time] seconds; does nothing if it is already playing.
static func play_music_for(ending: GameSession.Ending, fade_time: float) -> void:
	AudioController.play_music(MUSIC[ending], fade_time, MUSIC_VOLUMES[ending])


## Returns the picture set for [param ending], or null when there is none.
func _picture_for(ending: GameSession.Ending) -> Texture2D:
	match ending:
		GameSession.Ending.ESCAPE:
			return escape_picture
		GameSession.Ending.UNCOVERED:
			return uncovered_picture
		_:
			return caught_picture


## Whether leaving this card shows the credits: only after a winning ending, and only if a credits scene is set.
func _leads_to_credits() -> bool:
	return GameSession.ending != GameSession.Ending.CAUGHT and not credits_scene.is_empty()


## Readies a fresh run, then goes on to the credits with the music still playing after a win, or fades it out and returns to the main menu.
func _on_menu_button_pressed() -> void:
	var is_showing_credits: bool = _leads_to_credits()
	GameSession.start_new_game()
	if is_showing_credits:
		get_tree().change_scene_to_file(credits_scene)
		return
	AudioController.stop_music(music_fade_time)
	get_tree().change_scene_to_file(main_menu_scene)
