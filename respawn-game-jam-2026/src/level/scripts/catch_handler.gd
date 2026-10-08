class_name CatchHandler
extends Node
## Plays the moment the entity catches the player, takes a life, and respawns the player at the hub.
## On the last life the run ends with the Caught ending: the final cutscene plays if there is one, then the game goes to the run end scene, or quits if none is set.

## Emitted when the last life is lost, just before leaving the level.
signal run_ended

## Message shown while the screen is black; filled in with the lives left.
const CAUGHT_MESSAGE: String = "Caught. %d %s left"
## Message shown when the last life is lost and there is no final cutscene to say so.
const GAME_OVER_MESSAGE: String = "Game Over"

## Where the player comes back after being caught.
@export var spawn_point: Node3D
## Scene to load when the last life is lost, normally the ending screen; leave empty to quit the game instead.
@export_file("*.tscn") var run_end_scene: String = ""
## Cutscene played when the last life is lost, before the run end scene; leave empty for a Game Over message instead.
@export var final_cutscene: CaughtCutscene
## Name in the sound library of the sound played as the player is caught; leave empty for none.
@export var caught_sound: StringName = &"entity_caught"
## Time the view takes to snap toward the entity, in seconds.
@export var turn_time: float = 0.15
## Time the player stares at the entity after turning, before the fade, in seconds.
@export var hold_time: float = 1.45
## How quickly the view catches up with the entity's face while the player stares at it, as a rate per second; higher is tighter.
@export var follow_speed: float = 12.0
## How far the camera jolts at the start of the shake, in meters.
@export var shake_strength: float = 0.08
## Time the screen takes to cut to black after the stare, in seconds.
@export var fade_out_time: float = 0.2
## Time the screen takes to fade back in after the respawn, in seconds.
@export var fade_in_time: float = 0.6
## Time the black screen and its message stay up, in seconds.
@export var message_time: float = 1.6
## Time the screen stays black and silent between the last catch and the final cutscene, in seconds.
@export var cutscene_black_time: float = 2.0
## Time the screen takes to fade in on the final cutscene, and out of it again, in seconds.
@export var cutscene_fade_time: float = 0.8

var _player: Player
var _entities: Array[Entity] = []
var _is_handling: bool = false
var _watched: Entity

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
		entity.player_caught.connect(_on_entity_player_caught.bind(entity))


## Keeps the player's view on the face of the entity that caught them, which moves as its animation plays.
func _process(delta: float) -> void:
	if _watched != null:
		_player.look_toward(_watched.face_position(), minf(follow_speed * delta, 1.0))


## Shakes the view as it snaps toward [param entity], fades out, and then respawns the player or ends the run.
func _on_entity_player_caught(entity: Entity) -> void:
	if _is_handling:
		return
	_is_handling = true
	_player.is_input_enabled = false
	AudioController.play_sound(caught_sound)
	_player.shake_camera(shake_strength, turn_time + hold_time)
	await _player.face_toward(entity.face_position(), turn_time).finished
	_watched = entity
	await get_tree().create_timer(hold_time).timeout
	var lives_left: int = GameSession.lose_life()
	_message.text = _message_for(lives_left)
	await _fade_to(1.0, fade_out_time)
	_watched = null
	if lives_left <= 0 and final_cutscene != null:
		await _play_final_cutscene()
		_end_run()
		return
	await get_tree().create_timer(message_time).timeout
	if lives_left <= 0:
		_end_run()
		return
	_player.respawn_at(spawn_point)
	for each_entity: Entity in _entities:
		each_entity.reset_after_catch()
	await _fade_to(0.0, fade_in_time)
	_player.is_input_enabled = true
	_is_handling = false


## Returns the black-screen message for [param lives_left]; nothing when the final cutscene is about to speak for itself.
func _message_for(lives_left: int) -> String:
	if lives_left <= 0:
		return "" if final_cutscene != null else GAME_OVER_MESSAGE
	return CAUGHT_MESSAGE % [lives_left, "life" if lives_left == 1 else "lives"]


## Fades the black overlay to [param alpha] over [param duration] seconds and waits until it is done.
func _fade_to(alpha: float, duration: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_fade, "modulate:a", alpha, duration)
	await tween.finished


## Quiets the level, holds on black, shows the final cutscene out of it, and returns with the screen black again.
func _play_final_cutscene() -> void:
	_player.hide_hud()
	# Back to the hub, so the player's own body cannot be standing in the shot.
	_player.respawn_at(spawn_point)
	for each_entity: Entity in _entities:
		# Back to its calm state first, which is what silences the heartbeat, then stopped where it stands.
		each_entity.reset_after_catch()
		each_entity.process_mode = Node.PROCESS_MODE_DISABLED
	AudioController.stop_all_sounds()
	AudioController.stop_music(cutscene_fade_time)
	await get_tree().create_timer(cutscene_black_time).timeout
	final_cutscene.set_up()
	await _fade_to(0.0, cutscene_fade_time)
	await final_cutscene.play()
	await _fade_to(1.0, cutscene_fade_time)


## Ends the run as Caught: loads the run end scene if one is set, otherwise quits the game.
func _end_run() -> void:
	run_ended.emit()
	if run_end_scene.is_empty():
		# Test levels leave the scene unset, so they close the game instead.
		get_tree().quit()
		return
	GameSession.ending = GameSession.Ending.CAUGHT
	get_tree().change_scene_to_file(run_end_scene)
