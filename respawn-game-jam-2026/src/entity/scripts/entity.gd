class_name Entity
extends CharacterBody3D
## Creature that roams between patrol points, and goes to check wherever it last noticed the player.
## It notices a player in view who is moving or has the light on, or the spot their light lands on.

## Emitted when the entity switches to a different state.
signal state_changed(state: State)
## Emitted when the entity notices the player after not seeing them.
signal player_spotted

enum State { PAUSING, ROAMING, INVESTIGATING, SEARCHING }

## Fraction of its intended speed below which the entity counts as blocked.
const BLOCKED_SPEED_RATIO: float = 0.25
## How far the spot to check must move before the path is recalculated, in meters.
const RETARGET_DISTANCE: float = 0.5
## Physics layers that block or are the target of the entity's sight: world (1) and player (2).
const SIGHT_MASK: int = 0b11
## Height above the player's feet of the lower point the entity looks for, in meters.
const PLAYER_BODY_HEIGHT: float = 0.5
## Distance the lit spot is pulled off its surface before checking the view to it, in meters.
const LIT_SPOT_OFFSET: float = 0.05
## Physics layer of solid level geometry, doors included: world (1).
const WORLD_MASK: int = 0b1
## How far ahead the entity checks for a closed door, in meters.
const DOOR_REACH: float = 0.8
## Height above the entity's feet at which it checks for a door, in meters.
const DOOR_CHECK_HEIGHT: float = 1.0
## How far past a door the entity must be before closing it, clear of the swinging panel, in meters.
const DOOR_CLOSE_DISTANCE: float = 1.3
## Distance from a door within which the player keeps the entity from closing it, in meters.
const DOOR_PLAYER_CLEARANCE: float = 1.5

@export_group("Roaming")
## Points the entity wanders between, in no fixed order.
@export var patrol_points: Array[Node3D] = []
## Roaming speed, in meters per second.
@export var roam_speed: float = 1.8
## Time spent standing at each patrol point, in seconds.
@export var pause_time: float = 2.0

@export_group("Senses")
## How far the entity can see, in meters.
@export var sight_range: float = 12.0
## Half the width of the entity's view, in degrees from straight ahead.
@export var sight_angle: float = 60.0

@export_group("Investigating")
## Speed while heading to the spot it is checking, in meters per second.
@export var investigate_speed: float = 3.8
## Time spent looking around after reaching that spot, in seconds.
@export var search_time: float = 3.0
## How fast it turns while looking around, in degrees per second.
@export var search_turn_speed: float = 90.0

@export_group("Movement")
## How fast the body turns to face where it is going, in degrees per second.
@export var turn_speed: float = 240.0
## Time the entity may be blocked before it gives up on a destination, in seconds.
@export var stuck_time: float = 1.5

## What the entity is doing right now.
var state: State = State.PAUSING
## Last place the entity noticed the player, or was told to check.
var last_known_position: Vector3

var _pause_left: float = 0.0
var _search_left: float = 0.0
var _blocked_for: float = 0.0
var _patrol_point: Node3D
var _player: Player
var _sees_player: bool = false
var _door_to_close: Door
var _door_start_side: float = 0.0

@onready var _agent: NavigationAgent3D = $NavigationAgent3D
@onready var _eyes: Marker3D = $Eyes


## Finds the player and starts with a pause, which also gives the navigation map time to load.
func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player") as Player
	_pause_left = pause_time


## Checks for the player, runs the current state, then applies gravity and moves the body.
func _physics_process(delta: float) -> void:
	_update_sight()
	match state:
		State.PAUSING:
			_process_pausing(delta)
		State.ROAMING:
			_process_roaming(delta)
		State.INVESTIGATING:
			_process_investigating(delta)
		State.SEARCHING:
			_process_searching(delta)
	_close_door_behind()
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


## Sends the entity to check [param spot], such as where it last noticed the player.
func investigate(spot: Vector3) -> void:
	last_known_position = spot
	if state != State.INVESTIGATING or spot.distance_to(_agent.target_position) > RETARGET_DISTANCE:
		_agent.target_position = spot
	if state != State.INVESTIGATING:
		_blocked_for = 0.0
		_set_state(State.INVESTIGATING)


## Whether the entity can currently see the player.
func sees_player() -> bool:
	return _sees_player


## Looks for the player, and heads for where they are whenever they can be seen.
func _update_sight() -> void:
	var can_see: bool = _can_see_player()
	if can_see:
		if not _sees_player:
			player_spotted.emit()
		investigate(_player.global_position)
	_sees_player = can_see


## Stands still until the pause runs out, then heads for a patrol point.
func _process_pausing(delta: float) -> void:
	_stop()
	_pause_left -= delta
	if _pause_left <= 0.0:
		_start_roaming()


## Walks to the patrol point, pausing on arrival.
func _process_roaming(delta: float) -> void:
	if _follow_path(roam_speed, delta):
		_start_pausing()


## Hurries to the spot being checked, then looks around on arrival.
func _process_investigating(delta: float) -> void:
	if _follow_path(investigate_speed, delta):
		_start_searching()


## Turns on the spot looking for the player, then goes back to roaming.
func _process_searching(delta: float) -> void:
	_stop()
	rotation.y += deg_to_rad(search_turn_speed) * delta
	_search_left -= delta
	if _search_left <= 0.0:
		_start_pausing()


## Stops and waits before choosing the next patrol point.
func _start_pausing() -> void:
	_pause_left = pause_time
	_set_state(State.PAUSING)


## Picks a patrol point and sets off toward it, or keeps pausing when there is none.
func _start_roaming() -> void:
	_patrol_point = _pick_patrol_point()
	if _patrol_point == null:
		_pause_left = pause_time
		return
	_agent.target_position = _patrol_point.global_position
	_blocked_for = 0.0
	_set_state(State.ROAMING)


## Starts looking around the spot it just reached.
func _start_searching() -> void:
	_search_left = search_time
	_set_state(State.SEARCHING)


## Moves one step along the current path at [param speed]; returns true on arrival or when stuck.
func _follow_path(speed: float, delta: float) -> bool:
	if _agent.is_navigation_finished() or _is_stuck(speed, delta):
		return true
	var to_next: Vector3 = _agent.get_next_path_position() - global_position
	to_next.y = 0.0
	var direction: Vector3 = to_next.normalized()
	_open_door_ahead(direction)
	_face(direction, delta)
	var step_speed: float = speed * _alignment_with(direction)
	velocity.x = direction.x * step_speed
	velocity.z = direction.z * step_speed
	return false


## Opens a closed door just ahead in [param direction], of any hue, swinging it away from the entity.
func _open_door_ahead(direction: Vector3) -> void:
	var from: Vector3 = global_position + Vector3.UP * DOOR_CHECK_HEIGHT
	var query := PhysicsRayQueryParameters3D.create(from, from + direction * DOOR_REACH, WORLD_MASK, [get_rid()])
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	var door: Door = Door.find_owner(hit.collider)
	if door != null and not door.is_open:
		door.open_away_from(self)
		_blocked_for = 0.0
		if state == State.ROAMING:
			_door_to_close = door
			_door_start_side = signf(door.to_local(global_position).z)


## While not chasing, closes the door it opened once it is through and clear, unless the player is beside it.
func _close_door_behind() -> void:
	if _door_to_close == null:
		return
	if state == State.INVESTIGATING:
		_door_to_close = null
		return
	var offset: float = _door_to_close.to_local(global_position).z
	var is_through: bool = signf(offset) != _door_start_side and absf(offset) >= DOOR_CLOSE_DISTANCE
	if not is_through:
		return
	if _player != null and _player.global_position.distance_to(_door_to_close.global_position) < DOOR_PLAYER_CLEARANCE:
		return
	_door_to_close.close()
	_door_to_close = null


## Cancels any sideways movement.
func _stop() -> void:
	velocity.x = 0.0
	velocity.z = 0.0


## Returns a random patrol point other than the current one, or null when none are set.
func _pick_patrol_point() -> Node3D:
	var candidates: Array[Node3D] = []
	for point: Node3D in patrol_points:
		if point != null and point != _patrol_point:
			candidates.append(point)
	if candidates.is_empty():
		return _patrol_point
	return candidates.pick_random()


## Whether the entity notices the player, either directly or by spotting their flashlight's light.
func _can_see_player() -> bool:
	if _player == null:
		return false
	return _sees_player_body() or _sees_flashlight_spot()


## Whether the player is noticeable, and their head or body is in view with nothing in between.
func _sees_player_body() -> bool:
	if not _is_noticeable(_player):
		return false
	var body_point: Vector3 = _player.global_position + Vector3.UP * PLAYER_BODY_HEIGHT
	for point: Vector3 in [_player.head.global_position, body_point]:
		if _is_in_view(point) and _has_line_of_sight(point):
			return true
	return false


## Whether the spot the player's beam lands on is in view, which tells the entity where the light comes from.
func _sees_flashlight_spot() -> bool:
	if _player.flashlight == null:
		return false
	var hit: Dictionary = _player.flashlight.find_lit_spot()
	if hit.is_empty():
		return false
	var spot: Vector3 = hit.position + hit.normal * LIT_SPOT_OFFSET
	return _is_in_view(spot) and _has_clear_view_to(spot)


## Whether [param player] gives themselves away, by moving or by having the flashlight on.
func _is_noticeable(player: Player) -> bool:
	var light_on: bool = player.flashlight != null and player.flashlight.is_on
	return player.is_moving() or light_on


## Whether [param point], in global space, is within the entity's sight range and view angle.
func _is_in_view(point: Vector3) -> bool:
	var to_point: Vector3 = point - _eyes.global_position
	if to_point.length() > sight_range:
		return false
	return to_point.normalized().dot(-global_basis.z) >= cos(deg_to_rad(sight_angle))


## Whether a straight line from the eyes to [param point] reaches the player before any wall or door.
func _has_line_of_sight(point: Vector3) -> bool:
	var query := PhysicsRayQueryParameters3D.create(_eyes.global_position, point, SIGHT_MASK, [get_rid()])
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	return not hit.is_empty() and hit.collider == _player


## Whether a straight line from the eyes to [param point] meets nothing on the way.
func _has_clear_view_to(point: Vector3) -> bool:
	var query := PhysicsRayQueryParameters3D.create(_eyes.global_position, point, SIGHT_MASK, [get_rid()])
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()


## Whether the body has barely moved at [param speed] for longer than the stuck time.
func _is_stuck(speed: float, delta: float) -> bool:
	if get_real_velocity().length() < speed * BLOCKED_SPEED_RATIO:
		_blocked_for += delta
	else:
		_blocked_for = 0.0
	return _blocked_for >= stuck_time


## Turns the body toward [param direction] at the turn speed.
func _face(direction: Vector3, delta: float) -> void:
	if direction.is_zero_approx():
		return
	var target_yaw: float = atan2(-direction.x, -direction.z)
	rotation.y = rotate_toward(rotation.y, target_yaw, deg_to_rad(turn_speed) * delta)


## Returns 1 when the body faces [param direction], falling to 0 when it faces sideways or away.
func _alignment_with(direction: Vector3) -> float:
	return maxf(direction.dot(-global_basis.z), 0.0)


## Switches to [param new_state] and announces it if it changed.
func _set_state(new_state: State) -> void:
	if new_state == state:
		return
	state = new_state
	state_changed.emit(state)
