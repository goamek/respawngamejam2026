class_name Entity
extends CharacterBody3D
## Roaming creature that walks between patrol points using the level's navigation mesh.
## Sight, reaction to light, and catching the player are added in later steps.

## Emitted when the entity switches to a different state.
signal state_changed(state: State)

enum State { PAUSING, ROAMING }

## Fraction of its intended speed below which the entity counts as blocked.
const BLOCKED_SPEED_RATIO: float = 0.25

@export_group("Roaming")
## Points the entity wanders between, in no fixed order.
@export var patrol_points: Array[Node3D] = []
## Roaming speed, in meters per second.
@export var roam_speed: float = 1.8
## Time spent standing at each patrol point, in seconds.
@export var pause_time: float = 2.0

@export_group("Movement")
## How fast the body turns to face where it is going, in degrees per second.
@export var turn_speed: float = 240.0
## Time the entity may be blocked before it gives up on a destination, in seconds.
@export var stuck_time: float = 1.5

## What the entity is doing right now.
var state: State = State.PAUSING

var _pause_left: float = 0.0
var _blocked_for: float = 0.0
var _patrol_point: Node3D

@onready var _agent: NavigationAgent3D = $NavigationAgent3D


## Starts with a pause, which also gives the navigation map time to load.
func _ready() -> void:
	_pause_left = pause_time


## Runs the current state, then applies gravity and moves the body.
func _physics_process(delta: float) -> void:
	match state:
		State.PAUSING:
			_process_pausing(delta)
		State.ROAMING:
			_process_roaming(delta)
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


## Stands still until the pause runs out, then heads for a patrol point.
func _process_pausing(delta: float) -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	_pause_left -= delta
	if _pause_left <= 0.0:
		_start_roaming()


## Walks along the path to the patrol point, pausing on arrival or when blocked for too long.
func _process_roaming(delta: float) -> void:
	if _agent.is_navigation_finished() or _is_stuck(delta):
		_start_pausing()
		return
	var to_next: Vector3 = _agent.get_next_path_position() - global_position
	to_next.y = 0.0
	var direction: Vector3 = to_next.normalized()
	_face(direction, delta)
	var speed: float = roam_speed * _alignment_with(direction)
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed


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


## Returns a random patrol point other than the current one, or null when none are set.
func _pick_patrol_point() -> Node3D:
	var candidates: Array[Node3D] = []
	for point: Node3D in patrol_points:
		if point != null and point != _patrol_point:
			candidates.append(point)
	if candidates.is_empty():
		return _patrol_point
	return candidates.pick_random()


## Whether the body has barely moved for longer than the stuck time, such as against a closed door.
func _is_stuck(delta: float) -> bool:
	if get_real_velocity().length() < roam_speed * BLOCKED_SPEED_RATIO:
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
