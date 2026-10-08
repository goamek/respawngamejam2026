class_name Basketball
extends RigidBody3D
## Ball that rolls and bounces when the player walks into it; set dressing, not something to pick up.
## A ball that gets out of the level is put back where it started.

# Its scene puts it on a layer of its own (5) that the player and the enemy do not collide with, while the ball
# collides with them: they walk straight on, and the ball is the one that gives way.

## Height below which the ball has left the level and is put back, in meters.
const FALL_LIMIT: float = -5.0

var _home: Transform3D


## Remembers where the ball starts.
func _ready() -> void:
	_home = global_transform


## Puts the ball back at its starting place, at rest, once it has fallen out of the level.
func _physics_process(_delta: float) -> void:
	if global_position.y > FALL_LIMIT:
		return
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	global_transform = _home
