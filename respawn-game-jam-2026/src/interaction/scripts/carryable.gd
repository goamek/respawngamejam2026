class_name Carryable
extends Interactable
## Lets the player pick up, carry, and drop its parent RigidBody3D.
## While carried, the body is pulled toward a hold point and still collides with the world.

## Emitted when the body is let go, by the player or because it got stuck.
signal dropped

## Name that sockets use to tell what kind of item this is, such as "apple".
@export var item_id: StringName = &""
## How strongly the body is pulled to the hold point; its speed per meter of distance.
@export var follow_strength: float = 20.0
## Fastest the body may travel while following the hold point, in meters per second.
@export var max_follow_speed: float = 10.0
## Distance from the hold point at which the body is dropped, in meters.
@export var break_distance: float = 3.0
## Name in the sound library of the sound played when the player picks this up; leave empty for none.
@export var pickup_sound: StringName = &"pickup"

## Whether the body is sitting in a socket, where it cannot be picked up.
var is_placed: bool = false

var _hold_point: Node3D
var _home: Transform3D
var _has_home: bool = false
var _carrier: PhysicsBody3D
var _gravity_scale: float

@onready var _body: RigidBody3D = get_parent() as RigidBody3D


## Checks the parent is a rigid body and waits idle until picked up.
func _ready() -> void:
	assert(_body != null, "Carryable must be a child of a RigidBody3D.")
	set_physics_process(false)


## Pulls the body toward what holds it; a carried body is dropped if it falls too far behind.
func _physics_process(_delta: float) -> void:
	var offset: Vector3 = _hold_point.global_position - _body.global_position
	if not is_placed and offset.length() > break_distance:
		drop()
		return
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
	# Jumped straight there, since the socket's own body is often in the way of a glide,
	# then held the way a carried body is so it stays put without being frozen.
	_teleport(slot.global_transform)
	_follow(slot)


## Frees the body from the player or a socket and puts it back where it was first picked up.
func return_home() -> void:
	drop()
	if is_placed:
		is_placed = false
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


## Floats the body and starts pulling it toward [param point].
func _follow(point: Node3D) -> void:
	_hold_point = point
	_gravity_scale = _body.gravity_scale
	_body.gravity_scale = 0.0
	set_physics_process(true)


## Stops pulling the body and gives it its weight back.
func _stop_following() -> void:
	set_physics_process(false)
	_body.gravity_scale = _gravity_scale
	_body.linear_velocity = Vector3.ZERO
	_hold_point = null
