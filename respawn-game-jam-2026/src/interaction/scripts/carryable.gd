class_name Carryable
extends Interactable
## Lets the player pick up, carry, and drop its parent RigidBody3D.
## While carried, the body is pulled toward a hold point and still collides with the world.

## Emitted when the body is let go, by the player or because it got stuck.
signal dropped

## Physics layer of solid level geometry that a held body must stay in front of: world (1).
const WORLD_MASK: int = 0b1
## How far below where it was first picked up a body may fall before it is put back there, in meters.
const FALL_LIMIT: float = 10.0

## Name that sockets use to tell what kind of item this is, such as "apple".
@export var item_id: StringName = &""
## How strongly the body is pulled to the hold point; its speed per meter of distance.
@export var follow_strength: float = 20.0
## Fastest the body may travel while following the hold point, in meters per second.
@export var max_follow_speed: float = 10.0
## Distance from the hold point at which the body is dropped, in meters.
@export var break_distance: float = 3.0
## Gap kept between the held body's center and a floor or wall the holder is aiming it into, in meters; about half the body's size.
@export var hold_clearance: float = 0.12
## Name in the sound library of the sound played when the player picks this up; leave empty for none.
@export var pickup_sound: StringName = &"pickup"

## Whether the body is sitting in a socket, where it cannot be picked up.
var is_placed: bool = false

var _hold_point: Node3D
var _home: Transform3D
var _has_home: bool = false
var _carrier: PhysicsBody3D
var _gravity_scale: float
var _free_layer: int
var _free_mask: int

@onready var _body: RigidBody3D = get_parent() as RigidBody3D


## Checks the parent is a rigid body and waits idle until picked up.
func _ready() -> void:
	assert(_body != null, "Carryable must be a child of a RigidBody3D.")
	set_physics_process(false)


## Pulls the body toward what holds it, dropping it if it falls too far behind, and rescues a body that has left the level.
func _physics_process(_delta: float) -> void:
	if _body.global_position.y < _home.origin.y - FALL_LIMIT:
		# Nothing should get a body out of the level, but one that does would be lost for good, and a puzzle with it.
		return_home()
		return
	if _hold_point == null:
		return
	if not is_placed and _hold_point.global_position.distance_to(_body.global_position) > break_distance:
		drop()
		return
	var offset: Vector3 = _hold_target() - _body.global_position
	_body.linear_velocity = (offset * follow_strength).limit_length(max_follow_speed)
	_body.angular_velocity = Vector3.ZERO


## Whether [param player] can pick this up; never while it sits in a socket.
func can_interact(player: Player, aim_point: Vector3) -> bool:
	return not is_placed and super(player, aim_point)


## Asks [param player] to start carrying this object.
func interact(player: Player) -> void:
	super(player)
	player.interactor.carry(self)


## Starts following [param hold_point] and stops colliding with [param carrier], with the pickup sound.
func pick_up(hold_point: Node3D, carrier: PhysicsBody3D) -> void:
	AudioController.play_sound(pickup_sound)
	if not _has_home:
		_home = _body.global_transform
		_has_home = true
	_carrier = carrier
	_body.add_collision_exception_with(carrier)
	# Left running from here on, so a body that falls out of the level later is still noticed.
	set_physics_process(true)
	_follow(hold_point)


## Lets go of a carried body so it falls and collides normally again.
func drop() -> void:
	if _carrier == null:
		return
	_body.remove_collision_exception_with(_carrier)
	_carrier = null
	_stop_following()
	dropped.emit()


## Lets go of the body and holds it at [param slot] instead, where it can no longer be picked up.
func place_at(slot: Node3D) -> void:
	drop()
	is_placed = true
	# A placed body is only for show. Left solid, it would sit in the way of the player's aim
	# at the socket, and the next item would be dropped beside the socket instead of placed in it.
	_free_layer = _body.collision_layer
	_free_mask = _body.collision_mask
	_body.collision_layer = 0
	_body.collision_mask = 0
	# Jumped straight there, then held the way a carried body is so it stays put without being frozen.
	_teleport(slot.global_transform)
	_follow(slot)


## Frees the body from the player or a socket and puts it back where it was first picked up.
func return_home() -> void:
	drop()
	if is_placed:
		is_placed = false
		_body.collision_layer = _free_layer
		_body.collision_mask = _free_mask
		_stop_following()
	if _has_home:
		_teleport(_home)


## Moves the body to [param spot], in global space, at rest.
func _teleport(spot: Transform3D) -> void:
	# Set through the physics server: a rigid body moved by its node transform
	# while handling input stays where it was.
	PhysicsServer3D.body_set_state(_body.get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM, spot)
	_body.linear_velocity = Vector3.ZERO
	_body.angular_velocity = Vector3.ZERO


## Returns where the body should be pulled to: the hold point, or just short of any floor or wall between the holder and it.
func _hold_target() -> Vector3:
	var target: Vector3 = _hold_point.global_position
	if is_placed:
		return target
	# The hold point is a fixed reach in front of the holder's head, so aiming at the floor
	# puts it underground, and a small body pulled toward it can be dragged through.
	var from: Vector3 = (_hold_point.get_parent() as Node3D).global_position
	var reach: Vector3 = target - from
	var past_target: Vector3 = target + reach.normalized() * hold_clearance
	var query := PhysicsRayQueryParameters3D.create(from, past_target, WORLD_MASK, [_body.get_rid(), _carrier.get_rid()])
	var hit: Dictionary = _body.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return target
	return hit.position + hit.normal * hold_clearance


## Floats the body and starts pulling it toward [param point].
func _follow(point: Node3D) -> void:
	_hold_point = point
	_gravity_scale = _body.gravity_scale
	_body.gravity_scale = 0.0


## Stops pulling the body and gives it its weight back.
func _stop_following() -> void:
	_body.gravity_scale = _gravity_scale
	_body.linear_velocity = Vector3.ZERO
	_hold_point = null
