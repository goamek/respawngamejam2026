class_name CatchHandler
extends Node
## Plays the moment the entity catches the player, takes a life, and respawns the player at the hub.
## On the last life the run ends: the game goes to the main menu, or quits if none is set.

## Emitted when the last life is lost, just before leaving the level.
signal run_ended

## Message shown while the screen is black; filled in with the lives left.
const CAUGHT_MESSAGE: String = "Caught. %d %s left"
## Message shown when the last life is lost.
const GAME_OVER_MESSAGE: String = "Caught. No lives left"

## Where the player comes back after being caught.
@export var spawn_point: Node3D
## Scene to load when the last life is lost; leave empty to quit the game instead.
@export_file("*.tscn") var main_menu_scene: String = ""
## Time the view takes to snap toward the entity, in seconds.
@export var turn_time: float = 0.15
## Time the player stares at the entity after turning, before the fade, in seconds.
@export var hold_time: float = 0.45
## How far the camera jolts at the start of the shake, in meters.
@export var shake_strength: float = 0.08
## Time the screen takes to fade to or from black, in seconds.
@export var fade_time: float = 0.6
## Time the black screen and its message stay up, in seconds.
@export var message_time: float = 1.6

var _player: Player
var _entities: Array[Entity] = []
var _is_handling: bool = false

@onready var _fade: ColorRect = $Overlay/Fade
@onready var _message: Label = $Overlay/Fade/Message


## Finds the player and every entity in the level, and listens for catches.
func _ready() -> void:
	assert(spawn_point != null, "CatchHandler needs a spawn point.")
	_player = get_tree().get_first_node_in_group("player") as Player
	_fade.modulate.a = 0.0
	for node: Node in get_tree().get_nodes_in_group("entity"):
		var entity: Entity = node as Entity
		_entities.append(entity)
		entity.player_caught.connect(_on_player_caught.bind(entity))


## Shakes the view as it snaps toward [param entity], fades out, and then respawns the player or ends the run.
func _on_player_caught(entity: Entity) -> void:
	if _is_handling:
		return
	_is_handling = true
	_player.controls_enabled = false
	_player.shake_camera(shake_strength, turn_time + hold_time)
	await _player.face_toward(entity.eye_position(), turn_time).finished
	await get_tree().create_timer(hold_time).timeout
	var lives_left: int = GameSession.lose_life()
	_message.text = _message_for(lives_left)
	await _fade_to(1.0)
	await get_tree().create_timer(message_time).timeout
	if lives_left <= 0:
		_end_run()
		return
	_player.respawn_at(spawn_point)
	for each_entity: Entity in _entities:
		each_entity.reset_to_start()
	await _fade_to(0.0)
	_player.controls_enabled = true
	_is_handling = false


## Returns the black-screen message for [param lives_left].
func _message_for(lives_left: int) -> String:
	if lives_left <= 0:
		return GAME_OVER_MESSAGE
	return CAUGHT_MESSAGE % [lives_left, "life" if lives_left == 1 else "lives"]


## Fades the black overlay to [param alpha] and waits until it is done.
func _fade_to(alpha: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_fade, "modulate:a", alpha, fade_time)
	await tween.finished


## Ends the run: loads the main menu with a fresh run if one is set, otherwise quits the game.
func _end_run() -> void:
	run_ended.emit()
	if main_menu_scene.is_empty():
		# STUB: quits the game until a main menu exists
		get_tree().quit()
		return
	GameSession.start_new_game()
	get_tree().change_scene_to_file(main_menu_scene)
