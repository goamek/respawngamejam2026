class_name Heartbeat
extends Node
## Plays the player's heartbeat while the entity is a threat: during the first sighting's stare, and whenever it is not calmly roaming.
## The beat quickens while the entity is coming for something.

## Entity whose mood sets the heartbeat.
@export var entity: Entity
## First sighting whose stare also starts the heartbeat; leave empty if the level has none.
@export var first_sighting: FirstSighting
## Name in the sound library of one heartbeat; leave empty for none.
@export var beat_sound: StringName = &"heartbeat_pair"
## Time from one heartbeat to the next while the entity stares or searches, in seconds.
@export var tense_interval: float = 0.9
## Time from one heartbeat to the next while the entity is coming for the player or a noise, or catching, in seconds.
@export var chase_interval: float = 0.55

var _is_staring: bool = false
var _until_beat: float = 0.0


## Listens for the first sighting's stare beginning and ending.
func _ready() -> void:
	if first_sighting != null:
		first_sighting.started.connect(_on_first_sighting_started)
		first_sighting.ended.connect(_on_first_sighting_ended)


## Counts down to the next heartbeat while there is a threat, and falls silent when there is none.
func _process(delta: float) -> void:
	var interval: float = _beat_interval()
	if interval <= 0.0:
		# Ready to beat at once the next time a threat appears.
		_until_beat = 0.0
		return
	_until_beat -= delta
	if _until_beat <= 0.0:
		_until_beat = interval
		AudioController.play_sound(beat_sound)


## Returns the time between heartbeats for what the entity is doing now, or 0 when it is no threat.
func _beat_interval() -> float:
	match entity.state:
		Entity.State.INVESTIGATING, Entity.State.CATCHING:
			return chase_interval
		Entity.State.SEARCHING:
			return tense_interval
	return tense_interval if _is_staring else 0.0


## Starts the heartbeat for the stare.
func _on_first_sighting_started() -> void:
	_is_staring = true


## Hands the heartbeat back to the entity's own state once the stare is over.
func _on_first_sighting_ended() -> void:
	_is_staring = false
