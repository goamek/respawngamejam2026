class_name HandSway
extends Marker3D
## Gives the hand that holds the flashlight a little life: it bobs with each step, trails behind a turn of the view, and drifts as if breathing.
## Put it on the marker the flashlight hangs from; the arm follows the marker, so the whole arm moves with it.

# Only the hand's place and its roll change, never the way it points, so the beam stays aimed where the player looks.

## Player whose movement drives the sway.
@export var player: Player

@export_group("Walking")
## How far the hand swings from side to side as the player walks, in meters.
@export var walk_side: float = 0.012
## How far the hand rises and dips with each step, in meters.
@export var walk_lift: float = 0.01
## How far the hand rolls with each step, in degrees.
@export var walk_roll: float = 1.5
## How much of the walking sway is kept while crouched, as a fraction.
@export_range(0.0, 1.0) var crouch_share: float = 0.6

@export_group("Standing Still")
## How far the hand drifts up and down while standing still, in meters.
@export var idle_lift: float = 0.003
## How far the hand drifts from side to side while standing still, in meters.
@export var idle_side: float = 0.0015
## How many times a second the standing drift repeats.
@export var idle_rate: float = 0.25

@export_group("Turning")
## How far the hand trails behind for each radian per second the view turns, in meters.
@export var turn_trail: float = 0.006
## Furthest the hand trails behind a turn, in meters.
@export var turn_trail_limit: float = 0.02

@export_group("Smoothing")
## How quickly the sway settles into walking or back to standing, as a rate per second; higher is snappier.
@export var blend_speed: float = 6.0

var _rest: Transform3D
var _step_phase: float = 0.0
var _idle_phase: float = 0.0
var _walk_amount: float = 0.0
var _trail: Vector2 = Vector2.ZERO
var _last_yaw: float = 0.0
var _last_pitch: float = 0.0
var _has_last_view: bool = false


## Remembers where the hand rests, which every sway is measured from.
func _ready() -> void:
	_rest = transform


## Moves the hand for this frame.
func _process(delta: float) -> void:
	var speed: float = Vector2(player.velocity.x, player.velocity.z).length()
	var is_walking: bool = player.is_moving() and player.is_on_floor()
	_walk_amount = lerpf(_walk_amount, 1.0 if is_walking else 0.0, minf(blend_speed * delta, 1.0))
	if is_walking:
		# Tied to the ground covered, not to time: one full swing left and right for every two footsteps.
		_step_phase += speed * delta * PI / player.stride_length
	_idle_phase += delta * idle_rate * TAU
	var walk: float = _walk_amount * (crouch_share if player.is_crouching else 1.0)
	var still: float = 1.0 - _walk_amount
	var side: float = sin(_step_phase) * walk_side * walk + sin(_idle_phase * 0.5) * idle_side * still
	# Twice as fast as the side swing: the hand dips once for each foot.
	var lift: float = cos(_step_phase * 2.0) * walk_lift * walk + sin(_idle_phase) * idle_lift * still
	var roll: float = deg_to_rad(sin(_step_phase) * walk_roll * walk)
	_update_trail(delta)
	transform = _rest.translated(Vector3(side + _trail.x, lift + _trail.y, 0.0)).rotated_local(Vector3.BACK, roll)


## Works out how far the hand hangs back from where the view is turning to.
func _update_trail(delta: float) -> void:
	if delta <= 0.0:
		return
	# The player is not ready when this node is, so the first frame only notes where the view points.
	if not _has_last_view:
		_has_last_view = true
		_last_yaw = player.rotation.y
		_last_pitch = player.head.rotation.x
	var yaw_rate: float = angle_difference(_last_yaw, player.rotation.y) / delta
	var pitch_rate: float = angle_difference(_last_pitch, player.head.rotation.x) / delta
	_last_yaw = player.rotation.y
	_last_pitch = player.head.rotation.x
	# Turning left carries the view left, so the hand is left behind to the right; looking up leaves it lower.
	var wanted := Vector2(yaw_rate, -pitch_rate) * turn_trail
	wanted = wanted.limit_length(turn_trail_limit)
	_trail = _trail.lerp(wanted, minf(blend_speed * delta, 1.0))
