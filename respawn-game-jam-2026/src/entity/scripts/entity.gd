class_name Entity
extends CharacterBody3D
## Creature that roams between patrol points and checks wherever it last noticed the player.
## It catches the player when it reaches them while it can still see them.

## Emitted when the entity switches to a different state.
signal state_changed(state: State)
## Emitted when the entity notices the player after not seeing them.
signal player_spotted
## Emitted when the entity catches the player.
signal player_caught

enum State { PAUSING, ROAMING, INVESTIGATING, SEARCHING, CATCHING }

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
## Distance at which the player is caught whichever way the entity faces; the two bodies pass through each other, in meters.
const OVERLAP_DISTANCE: float = 0.3
## Tallest lip the entity can step onto, just above the 0.25 m the walkable area allows, in meters.
const STEP_HEIGHT: float = 0.3
## How far forward a step up carries the body, enough to land its middle on the lip, in meters.
const STEP_REACH: float = 0.35
## Animation library played in each state; each is one Mixamo file imported as a library.
const STATE_ANIMATIONS: Dictionary[State, StringName] = {
	State.PAUSING: &"idle",
	State.ROAMING: &"walk",
	State.INVESTIGATING: &"run",
	State.SEARCHING: &"search",
	State.CATCHING: &"catch",
}
## Closest the face comes to the player's eyes in a lunge, so it never passes through the camera, in meters.
const MIN_FACE_DISTANCE: float = 0.45
## Name Mixamo gives the single clip inside every library.
const CLIP_NAME: StringName = &"mixamo_com"

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

@export_group("Catching")
## How close the player must be to be caught, in meters.
@export var catch_reach: float = 1.2
## How far off straight ahead the player may be and still be caught, in degrees.
@export var catch_angle: float = 45.0
## Time after being reset during which the entity cannot catch, in seconds.
@export var catch_cooldown: float = 3.0
## Time the leap up to the player's eye level takes when catching, in seconds.
@export var catch_leap_time: float = 0.15
## Highest the body can leap off the floor when catching, in meters.
@export var catch_leap_limit: float = 1.0
## How far above the player's eye level the face ends up in the leap, in meters.
@export var catch_leap_above_eyes: float = 0.15
## How far the body lunges toward the player in the leap, in meters.
@export var catch_lunge_distance: float = 0.3

@export_group("Animation")
## How long one animation takes to fade into the next, in seconds.
@export var animation_blend_time: float = 0.25
## How many times faster than normal the catch animation plays.
@export var catch_animation_speed: float = 2.0

@export_group("Movement")
## How much faster the entity gets for each spectrum hue the player has unlocked, as a fraction of its speeds.
@export var speed_gain_per_hue: float = 0.05
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
var _catch_cooldown_left: float = 0.0
var _leap_face_height: float = 0.0
var _leap_face_gap: float = 0.0
var _start_transform: Transform3D

@onready var _agent: NavigationAgent3D = $NavigationAgent3D
@onready var _eyes: Marker3D = $Eyes
@onready var _model: Node3D = $Model
@onready var _face_marker: Marker3D = $Model/Skeleton3D/Head/Face
@onready var _animation: AnimationPlayer = $Model/AnimationPlayer


## Finds the player, remembers where it started, and begins with a pause while the navigation map loads.
func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player") as Player
	_start_transform = global_transform
	_pause_left = pause_time
	_play_state_animation()


## Checks for the player, tries to catch them, runs the current state, then moves the body.
## Open doors it bumps into stop being solid to it, so a door left open never traps it.
func _physics_process(delta: float) -> void:
	_update_sight()
	_try_catch(delta)
	match state:
		State.PAUSING:
			_process_pausing(delta)
		State.ROAMING:
			_process_roaming(delta)
		State.INVESTIGATING:
			_process_investigating(delta)
		State.SEARCHING:
			_process_searching(delta)
		State.CATCHING:
			_process_catching(delta)
	_close_door_behind()
	if not is_on_floor():
		velocity += get_gravity() * delta
	var wanted := Vector3(velocity.x, 0.0, velocity.z)
	move_and_slide()
	_pass_open_doors()
	_step_up(wanted)


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


## Returns the fixed point the entity sees from, in global space.
func eye_position() -> Vector3:
	return _eyes.global_position


## Returns where the entity's face is right now, following its animation, in global space.
func face_position() -> Vector3:
	return _face_marker.global_position


## Puts the entity back where it started, roaming afresh and briefly unable to catch.
func reset_to_start() -> void:
	global_transform = _start_transform
	velocity = Vector3.ZERO
	_sees_player = false
	_door_to_close = null
	_catch_cooldown_left = catch_cooldown
	_start_pausing()


## Looks for the player, and heads for where they are whenever they can be seen.
func _update_sight() -> void:
	var can_see: bool = _can_see_player()
	if can_see and state != State.CATCHING:
		if not _sees_player:
			player_spotted.emit()
		investigate(_player.global_position)
	_sees_player = can_see


## Catches the player when it can see them, they are within reach, and it is facing them.
func _try_catch(delta: float) -> void:
	_catch_cooldown_left = maxf(_catch_cooldown_left - delta, 0.0)
	if state == State.CATCHING or _catch_cooldown_left > 0.0 or not _sees_player:
		return
	if _is_off_limits(_player.global_position):
		return
	if _is_within_reach(_player.global_position):
		_set_state(State.CATCHING)
		_leap_at_player()
		player_caught.emit()


## Whether [param point] is within catching reach and within the catch angle of straight ahead.
## Points closer than [constant OVERLAP_DISTANCE] count whatever the angle, since bodies can overlap.
func _is_within_reach(point: Vector3) -> bool:
	var to_point: Vector3 = point - global_position
	to_point.y = 0.0
	var distance: float = to_point.length()
	if distance > catch_reach:
		return false
	if distance < OVERLAP_DISTANCE:
		return true
	return to_point.normalized().dot(-global_basis.z) >= cos(deg_to_rad(catch_angle))


## Stands still until the pause runs out, then heads for a patrol point.
func _process_pausing(delta: float) -> void:
	_stop()
	_pause_left -= delta
	if _pause_left <= 0.0:
		_start_roaming()


## Walks to the patrol point, pausing on arrival.
func _process_roaming(delta: float) -> void:
	if _follow_path(roam_speed * _speed_scale(), delta):
		_start_pausing()


## Hurries to the spot being checked; on arrival, turns to the player if still in sight, otherwise looks around.
func _process_investigating(delta: float) -> void:
	if not _follow_path(investigate_speed * _speed_scale(), delta):
		return
	if _sees_player:
		_stop()
		_face_point(last_known_position, delta)
	else:
		_start_searching()


## Turns on the spot looking for the player, then goes back to roaming.
func _process_searching(delta: float) -> void:
	_stop()
	rotation.y += deg_to_rad(search_turn_speed) * delta
	_search_left -= delta
	if _search_left <= 0.0:
		_start_pausing()


## Holds still facing the player until something resets the entity.
func _process_catching(delta: float) -> void:
	_stop()
	_face_point(_player.global_position, delta)
	_hold_face_in_place(delta)


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


## Moves one step along the current path at [param speed]; returns true on arrival, when stuck,
## or when the next step would take it into a room it is still kept out of.
func _follow_path(speed: float, delta: float) -> bool:
	if _agent.is_navigation_finished() or _is_stuck(speed, delta):
		return true
	var next_position: Vector3 = _agent.get_next_path_position()
	if _is_off_limits(next_position):
		_stop()
		return true
	var to_next: Vector3 = next_position - global_position
	to_next.y = 0.0
	var direction: Vector3 = to_next.normalized()
	_open_door_ahead(direction)
	_face(direction, delta)
	var step_speed: float = speed * _alignment_with(direction)
	velocity.x = direction.x * step_speed
	velocity.z = direction.z * step_speed
	return false


## Opens a closed door just ahead in [param direction], of any hue, swinging it away from the entity.
## A locked door is left alone.
func _open_door_ahead(direction: Vector3) -> void:
	var from: Vector3 = global_position + Vector3.UP * DOOR_CHECK_HEIGHT
	var query := PhysicsRayQueryParameters3D.create(from, from + direction * DOOR_REACH, WORLD_MASK, [get_rid()])
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	var door: Door = Door.find_owner(hit.collider)
	if door != null and not door.is_open and not door.is_locked:
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


## Stops colliding with each fully open door the entity has just walked into, until that door closes.
func _pass_open_doors() -> void:
	for index: int in get_slide_collision_count():
		var panel := get_slide_collision(index).get_collider() as PhysicsBody3D
		var door: Door = Door.find_owner(panel)
		if door == null or not door.is_open or door.is_swinging():
			continue
		# The walkable area is baked without doors, so a path can run straight through an open panel.
		add_collision_exception_with(panel)
		door.closed.connect(remove_collision_exception_with.bind(panel), CONNECT_ONE_SHOT)


## Lifts the body onto a low lip that blocked its move toward [param wanted], its intended sideways velocity.
func _step_up(wanted: Vector3) -> void:
	if wanted.is_zero_approx() or not is_on_floor() or not is_on_wall():
		return
	var rise: Vector3 = Vector3.UP * STEP_HEIGHT
	var reach: Vector3 = wanted.normalized() * STEP_REACH
	if test_move(global_transform, rise) or test_move(global_transform.translated(rise), reach):
		return
	# The same move is clear one step higher, so the obstacle is a lip and not a wall.
	global_position += rise + reach
	var landing := KinematicCollision3D.new()
	if test_move(global_transform, -rise, landing):
		global_position += landing.get_travel()


## Cancels any sideways movement.
func _stop() -> void:
	velocity.x = 0.0
	velocity.z = 0.0


## Whether [param point], in global space, is inside a safe room the entity is still kept out of.
func _is_off_limits(point: Vector3) -> bool:
	return SafeRoom.is_sheltered(get_tree(), point)


## Returns how many times its base speeds the entity moves at, which grows with each spectrum hue the player unlocks.
func _speed_scale() -> float:
	if _player == null or _player.flashlight == null:
		return 1.0
	var hue_count: int = 0
	for hue: Spectrum.Hue in _player.flashlight.unlocked_hues:
		if hue != Spectrum.Hue.WHITE:
			hue_count += 1
	return 1.0 + speed_gain_per_hue * hue_count


## Returns a random patrol point other than the current one and outside any room it is kept out of, or null when none are set.
func _pick_patrol_point() -> Node3D:
	var candidates: Array[Node3D] = []
	for point: Node3D in patrol_points:
		if point != null and point != _patrol_point and not _is_off_limits(point.global_position):
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


## Turns the body toward [param point], in global space, at the turn speed.
func _face_point(point: Vector3, delta: float) -> void:
	var to_point: Vector3 = point - global_position
	to_point.y = 0.0
	_face(to_point.normalized(), delta)


## Returns 1 when the body faces [param direction], falling to 0 when it faces sideways or away.
func _alignment_with(direction: Vector3) -> float:
	return maxf(direction.dot(-global_basis.z), 0.0)


## Switches to [param new_state] and announces it if it changed.
func _set_state(new_state: State) -> void:
	if new_state == state:
		return
	state = new_state
	if state != State.CATCHING:
		_land()
	_play_state_animation()
	state_changed.emit(state)


## Starts the leap: picks where the face is held, just above the player's eyes and a lunge closer to them.
## It is shorter than the player and hunches as it screams. Only the model moves; the body that collides stays put.
func _leap_at_player() -> void:
	var eyes: Vector3 = _player.settled_eye_position()
	var face: Vector3 = face_position()
	var gap: float = Vector2(face.x - eyes.x, face.z - eyes.z).length()
	_leap_face_height = eyes.y + catch_leap_above_eyes
	_leap_face_gap = gap - clampf(gap - MIN_FACE_DISTANCE, 0.0, catch_lunge_distance)


## Moves the model so its face reaches the leap spot in about the leap time, and then stays there.
## The catch animation hunches down and leans in; left alone, the face would drift and drag the player's view with it.
func _hold_face_in_place(delta: float) -> void:
	var eyes: Vector3 = _player.settled_eye_position()
	var face: Vector3 = face_position()
	var gap: float = Vector2(face.x - eyes.x, face.z - eyes.z).length()
	# The entity faces the player while catching, so its forward (-Z) closes the gap.
	var wanted := Vector3(
		0.0,
		clampf(_model.position.y + _leap_face_height - face.y, 0.0, catch_leap_limit),
		clampf(_model.position.z - (gap - _leap_face_gap), -catch_lunge_distance, catch_lunge_distance),
	)
	_model.position = _model.position.lerp(wanted, 1.0 - exp(-3.0 * delta / catch_leap_time))


## Puts the model back in place on the floor after a leap.
func _land() -> void:
	_model.position = Vector3.ZERO


## Fades into the animation that belongs to the current state.
func _play_state_animation() -> void:
	var speed: float = catch_animation_speed if state == State.CATCHING else 1.0
	_animation.play("%s/%s" % [STATE_ANIMATIONS[state], CLIP_NAME], animation_blend_time, speed)
