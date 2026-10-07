class_name EndingDirector
extends Node
## Ends the run from inside a level: takes the controls away, fades to black, and loads the ending screen.
## Connect whatever finishes the game to play_escape() or play_uncovered().

## Emitted when an ending starts, before the fade.
signal ending_started(ending: GameSession.Ending)

## Scene that shows the ending card.
@export_file("*.tscn") var ending_screen_scene: String = ""
## Time the screen takes to fade to black, in seconds.
@export var fade_time: float = 1.5
## Time the player is left looking at the uncovered entity before the fade, in seconds.
@export var uncovered_delay: float = 2.5

## Whether an ending is under way.
var is_playing: bool = false

@onready var _fade: ColorRect = $Overlay/Fade


## Starts with the screen clear.
func _ready() -> void:
	assert(not ending_screen_scene.is_empty(), "EndingDirector needs an ending screen scene.")
	_fade.modulate.a = 0.0


## Ends the run with the Escape ending.
func play_escape() -> void:
	play(GameSession.Ending.ESCAPE)


## Ends the run with the Uncovered ending, after a moment to look at the entity.
func play_uncovered() -> void:
	play(GameSession.Ending.UNCOVERED, uncovered_delay)


## Ends the run with [param ending] after [param delay] seconds; does nothing if an ending is already under way.
func play(ending: GameSession.Ending, delay: float = 0.0) -> void:
	if is_playing:
		return
	is_playing = true
	ending_started.emit(ending)
	var player := get_tree().get_first_node_in_group("player") as Player
	if player != null:
		player.controls_enabled = false
		player.clear_hint()
	if ending != GameSession.Ending.UNCOVERED:
		_freeze_entities()
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	var tween: Tween = create_tween()
	tween.tween_property(_fade, "modulate:a", 1.0, fade_time)
	await tween.finished
	GameSession.ending = ending
	get_tree().change_scene_to_file(ending_screen_scene)


## Stops every entity where it stands, so none can catch the player during the fade.
## The uncovered entity is left running: it is already harmless, and should keep moving while it is looked at.
func _freeze_entities() -> void:
	for node: Node in get_tree().get_nodes_in_group("entity"):
		node.process_mode = Node.PROCESS_MODE_DISABLED
