class_name FirstSighting
extends Node3D
## Scripted first meeting with the entity, which is kept asleep until then and stares once the door that shows it has swung open.
## Hiding makes it walk away and start roaming; waiting too long, coming close, or opening its door makes it attack.

## Emitted when the stare begins.
signal started
## Emitted when the player has hidden for long enough and the entity turns to leave.
signal player_hid
## Emitted when the entity stops waiting and comes for the player.
signal entity_attacked
## Emitted when the meeting is over, whichever way it went.
signal ended

## Whether the meeting happens at all; when off, the entity stays asleep for the whole game, which helps while testing puzzles.
@export var is_enabled: bool = true
## Entity that is kept asleep until the meeting.
@export var entity: Entity
## Region that puts the entity in place, entered before the player can see the watch spot.
@export var arrival_trigger: PlayerTrigger
# A path, not a node: doors live inside the school scene, which the editor's node picker cannot reach into.
## Door that begins the stare once it has swung fully open, because the watch spot can be seen through its doorway.
@export var stare_door_path: NodePath
## Region that begins the stare instead, for a level with no such door; leave empty otherwise.
@export var stare_trigger: PlayerTrigger
## Where the entity stands to watch; it faces the way the marker's -Z points.
@export var watch_spot: Marker3D
## Where the entity walks to once the player has hidden.
@export var leave_spot: Node3D
## Hiding spots that count for this meeting; crouching inside any of them makes the entity leave.
@export var hiding_spots: Array[HidingSpot] = []
## Door the entity watches through; the player opening it sets the entity off. Leave empty if there is none.
@export var watch_door_path: NodePath

@export_group("Tuning")
## Time the entity stares before it comes for a player who has not hidden, in seconds; 0 waits forever.
@export var patience: float = 8.0
## Time the player must stay hidden before the entity leaves, in seconds.
@export var hide_time: float = 1.5
## Distance from the entity within which the player sets it off, in meters.
@export var alarm_distance: float = 2.0
## How far the entity is lifted to bring its face up to a window, in meters.
@export var watch_rise: float = 0.5
## How far the entity tips its head while it stares, in degrees; positive leans the top of its head to the left as the player sees it.
@export_range(-90.0, 90.0) var head_tilt: float = 70.0
## Guidance shown on screen during the stare.
@export var hint: String = "Press Ctrl to crouch under a desk and hide (B on a controller)"

var _player: Player
var _watch_door: Door
var _patience_left: float = 0.0
var _hidden_for: float = 0.0


## Puts the entity to sleep and waits for the player to reach the triggers.
func _ready() -> void:
	set_physics_process(false)
	entity.visible = false
	entity.process_mode = Node.PROCESS_MODE_DISABLED
	if not is_enabled:
		return
	arrival_trigger.triggered.connect(_on_arrival_trigger_triggered)
	var stare_door := get_node_or_null(stare_door_path) as Door
	if stare_door != null:
		stare_door.fully_opened.connect(_on_stare_door_fully_opened, CONNECT_ONE_SHOT)
	if stare_trigger != null:
		stare_trigger.triggered.connect(_on_stare_trigger_triggered)


## Leaves once the player has hidden for long enough; attacks if they wait too long or come too close.
func _physics_process(delta: float) -> void:
	if _is_player_hidden():
		_hidden_for += delta
		if _hidden_for >= hide_time:
			_send_entity_away()
		return
	_hidden_for = 0.0
	_patience_left -= delta
	var is_out_of_patience: bool = patience > 0.0 and _patience_left <= 0.0
	var is_too_close: bool = _player.global_position.distance_to(entity.global_position) < alarm_distance
	if is_out_of_patience or is_too_close:
		_attack()


## Wakes the entity at the watch spot, staring toward the player.
func _place_entity() -> void:
	if entity.visible:
		return
	entity.global_transform = watch_spot.global_transform
	entity.visible = true
	entity.process_mode = Node.PROCESS_MODE_INHERIT
	entity.watch_player(watch_rise, head_tilt)


## Whether the player is crouched inside one of the hiding spots.
func _is_player_hidden() -> bool:
	for spot: HidingSpot in hiding_spots:
		if spot.is_hiding(_player):
			return true
	return false


## Ends the stare and sends the entity walking away, after which it roams.
func _send_entity_away() -> void:
	_finish()
	entity.leave_to(leave_spot.global_position)
	player_hid.emit()


## Ends the stare and sends the entity after the player.
func _attack() -> void:
	_finish()
	entity.investigate(_player.global_position)
	entity_attacked.emit()


## Stops watching the player and the door, and removes the hint.
func _finish() -> void:
	set_physics_process(false)
	_player.clear_hint()
	if _watch_door != null and _watch_door.opened.is_connected(_on_watch_door_opened):
		_watch_door.opened.disconnect(_on_watch_door_opened)
	ended.emit()


## Puts the entity in place while the player is still out of view.
func _on_arrival_trigger_triggered(_arriving_player: Player) -> void:
	_place_entity()


## Begins the stare at [param player], who has walked into the trigger.
func _on_stare_trigger_triggered(player: Player) -> void:
	_begin_stare(player)


## Sends the entity after the player, who has opened the door it was watching through.
func _on_watch_door_opened() -> void:
	_attack()


## Begins the stare for the player in the level.
func _on_stare_door_fully_opened() -> void:
	_begin_stare(get_tree().get_first_node_in_group("player") as Player)


## Begins the stare at [param player]: starts the countdown, shows the hint, and watches the door.
func _begin_stare(player: Player) -> void:
	if _player != null:
		return
	_place_entity()
	_player = player
	_patience_left = patience
	_hidden_for = 0.0
	_watch_door = get_node_or_null(watch_door_path) as Door
	if _watch_door != null:
		_watch_door.opened.connect(_on_watch_door_opened)
	_player.show_hint(hint)
	set_physics_process(true)
	started.emit()
