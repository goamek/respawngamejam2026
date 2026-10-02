class_name Carryable
extends Interactable
## Lets the player pick up, carry, and drop its parent RigidBody3D.
## While carried, the body is pulled toward a hold point and still collides with the world.

## Emitted when the body is let go, by the player or because it got stuck.
signal dropped

## How strongly the body is pulled to the hold point; its speed per meter of distance.
@export var follow_strength: float = 20.0
## Fastest the body may travel while following the hold point, in meters per second.
@export var max_follow_speed: float = 10.0
## Distance from the hold point at which the body is dropped, in meters.
@export var break_distance: float = 3.0

var _hold_point: Node3D
var _carrier: PhysicsBody3D
var _gravity_scale: float

@onready var _body: RigidBody3D = get_parent() as RigidBody3D


## Checks the parent is a rigid body and waits idle until picked up.
func _ready() -> void:
	assert(_body != null, "Carryable must be a child of a RigidBody3D.")
	set_physics_process(false)


## Pulls the body toward the hold point, and drops it if it falls too far behind.
func _physics_process(_delta: float) -> void:
	var offset: Vector3 = _hold_point.global_position - _body.global_position
	if offset.length() > break_distance:
		drop()
		return
	_body.linear_velocity = (offset * follow_strength).limit_length(max_follow_speed)
	_body.angular_velocity = Vector3.ZERO


## Asks [param player] to start carrying this object.
func interact(player: Player) -> void:
	super(player)
	player.interactor.carry(self)


## Starts following [param hold_point] and stops colliding with [param carrier].
func pick_up(hold_point: Node3D, carrier: PhysicsBody3D) -> void:
	_hold_point = hold_point
	_carrier = carrier
	_gravity_scale = _body.gravity_scale
	_body.gravity_scale = 0.0
	_body.add_collision_exception_with(carrier)
	set_physics_process(true)


## Lets go of the body so it falls and collides normally again.
func drop() -> void:
	if _hold_point == null:
		return
	set_physics_process(false)
	_body.gravity_scale = _gravity_scale
	_body.linear_velocity = Vector3.ZERO
	_body.remove_collision_exception_with(_carrier)
	_hold_point = null
	_carrier = null
	dropped.emit()
