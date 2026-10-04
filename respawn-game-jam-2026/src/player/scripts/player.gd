class_name Player
extends CharacterBody3D
## First-person player body: walks, sprints, crouches, and looks around.
## Mouse movement and the right stick both turn the body and tilt the head.

## Emitted when the player takes hold of [param flashlight].
signal flashlight_equipped(flashlight: Flashlight)

## Distance from the top of the body down to the eyes, in meters.
const EYE_OFFSET: float = 0.2
## How far the head can tilt up or down, in degrees.
const MAX_PITCH: float = 89.0
## Speed above which the player counts as moving to anything watching, in meters per second.
const MOVING_SPEED: float = 0.5

@export_group("Movement")
## Walking speed, in meters per second.
@export var walk_speed: float = 3.0
## Sprinting speed, in meters per second.
@export var sprint_speed: float = 5.5
## Crouched speed, in meters per second.
@export var crouch_speed: float = 1.5
## How fast the player speeds up and stops, in meters per second squared.
@export var acceleration: float = 30.0

@export_group("Look")
## Mouse look speed, in degrees per pixel of mouse movement.
@export var mouse_sensitivity: float = 0.1
## Right stick look speed, in degrees per second.
@export var stick_sensitivity: float = 150.0

@export_group("Crouch")
## Body height when standing, in meters.
@export var stand_height: float = 1.8
## Body height when crouched, in meters.
@export var crouch_height: float = 1.0
## How fast the body moves between standing and crouched, in meters per second.
@export var crouch_transition_speed: float = 4.0

## Whether the player is crouched, by choice or because something is overhead.
var is_crouching: bool = false
## Flashlight in the player's hand, or null while the hand is empty.
var flashlight: Flashlight
## Whether input moves, turns, and acts for the player; off during the caught moment.
var controls_enabled: bool = true

var _height: float
var _shake_strength: float = 0.0
var _shake_duration: float = 0.0
var _shake_left: float = 0.0

## Pivot at eye level that tilts up and down; the camera and anything held follow it.
@onready var head: Node3D = $Head
## Point in front of the camera where a held item sits.
@onready var hand: Marker3D = $Head/Hand
## Finds and uses whatever the player is aiming at, and carries objects.
@onready var interactor: Interactor = $Head/Interactor
@onready var _camera: Camera3D = $Head/Camera3D
@onready var _collision_shape: CollisionShape3D = $CollisionShape3D
@onready var _ceiling_check: ShapeCast3D = $CeilingCheck
@onready var _body_shape: CapsuleShape3D = _collision_shape.shape as CapsuleShape3D


## Captures the mouse, sizes the body from the exported heights, and takes any flashlight already in hand.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_height = stand_height
	_ceiling_check.position.y = crouch_height - _body_shape.radius
	_ceiling_check.target_position = Vector3(0.0, stand_height - crouch_height, 0.0)
	_apply_height()
	for child: Node in hand.get_children():
		if child is Flashlight:
			_hold_flashlight(child)


## Routes the pause action, and while controls are enabled, mouse look, the interact action, and hue changes.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		# STUB: frees the mouse until a real pause menu exists
		_toggle_mouse_capture()
	elif not controls_enabled:
		return
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var motion: InputEventMouseMotion = event
		_look(motion.relative * mouse_sensitivity)
	elif event.is_action_pressed("interact"):
		interactor.try_interact()
	elif flashlight != null:
		_handle_hue_input(event)


## Jitters the camera while a shake is running, easing off to nothing as it ends.
func _process(delta: float) -> void:
	if _shake_left <= 0.0:
		return
	_shake_left = maxf(_shake_left - delta, 0.0)
	var amount: float = _shake_strength * (_shake_left / _shake_duration)
	_camera.h_offset = randf_range(-amount, amount)
	_camera.v_offset = randf_range(-amount, amount)


## Applies stick look, the flashlight switch, crouch, and movement once per physics frame.
func _physics_process(delta: float) -> void:
	if controls_enabled:
		var stick: Vector2 = Input.get_vector("look_left", "look_right", "look_up", "look_down")
		_look(stick * stick_sensitivity * delta)
		# Polled, not read from events: a trigger sends an event for every bit of travel,
		# and each one past the deadzone would count as another press.
		if flashlight != null and Input.is_action_just_pressed("flashlight"):
			flashlight.toggle()
	_update_crouch(delta)
	_update_velocity(delta)
	move_and_slide()


## Whether the player is moving fast enough to be noticed.
func is_moving() -> bool:
	return Vector2(velocity.x, velocity.z).length() > MOVING_SPEED


## Turns the body and head over [param duration] seconds to look at [param point]; returns the running tween.
func face_toward(point: Vector3, duration: float) -> Tween:
	var to_point: Vector3 = point - head.global_position
	var target_yaw: float = atan2(-to_point.x, -to_point.z)
	var flat_distance: float = Vector2(to_point.x, to_point.z).length()
	var max_pitch: float = deg_to_rad(MAX_PITCH)
	var target_pitch: float = clampf(atan2(to_point.y, flat_distance), -max_pitch, max_pitch)
	var tween: Tween = create_tween().set_parallel()
	tween.tween_property(self, "rotation:y", rotation.y + angle_difference(rotation.y, target_yaw), duration)
	tween.tween_property(head, "rotation:x", target_pitch, duration)
	return tween


## Shakes the camera for [param duration] seconds, jolting up to [param strength] meters and fading out.
func shake_camera(strength: float, duration: float) -> void:
	_shake_strength = strength
	_shake_duration = duration
	_shake_left = duration


## Drops anything carried and moves the player to [param spawn], facing its way, standing still with a level head.
func respawn_at(spawn: Node3D) -> void:
	if interactor.carried != null:
		interactor.carried.drop()
	global_position = spawn.global_position
	rotation = Vector3(0.0, spawn.global_rotation.y, 0.0)
	head.rotation = Vector3.ZERO
	velocity = Vector3.ZERO


## Places [param item] in the player's hand and makes it the flashlight the player controls.
func equip_flashlight(item: Flashlight) -> void:
	if item.get_parent() == null:
		hand.add_child(item)
	else:
		item.reparent(hand, false)
	item.transform = Transform3D.IDENTITY
	_hold_flashlight(item)


## Makes [param item] the flashlight the player controls and announces it.
func _hold_flashlight(item: Flashlight) -> void:
	flashlight = item
	flashlight_equipped.emit(item)


## Turns the body and tilts the head by [param degrees], x for left and right, y for up and down.
func _look(degrees: Vector2) -> void:
	rotate_y(deg_to_rad(-degrees.x))
	var max_pitch: float = deg_to_rad(MAX_PITCH)
	head.rotation.x = clampf(head.rotation.x - deg_to_rad(degrees.y), -max_pitch, max_pitch)


## Crouches while the action is held, and stays crouched while something blocks standing up.
func _update_crouch(delta: float) -> void:
	var is_blocked: bool = is_crouching and _ceiling_check.is_colliding()
	var wants_crouch: bool = controls_enabled and Input.is_action_pressed("crouch")
	is_crouching = wants_crouch or is_blocked
	var target_height: float = crouch_height if is_crouching else stand_height
	_height = move_toward(_height, target_height, crouch_transition_speed * delta)
	_apply_height()


## Resizes the collision shape to the current height and keeps the head near its top.
func _apply_height() -> void:
	_body_shape.height = _height
	_collision_shape.position.y = _height / 2.0
	head.position.y = _height - EYE_OFFSET


## Applies gravity and moves horizontal velocity toward the input direction.
func _update_velocity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	var move_input: Vector2 = Vector2.ZERO
	if controls_enabled:
		move_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var target: Vector3 = global_basis * Vector3(move_input.x, 0.0, move_input.y) * _current_speed()
	velocity.x = move_toward(velocity.x, target.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target.z, acceleration * delta)


## Returns the top speed for the current state: crouched, sprinting, or walking.
func _current_speed() -> float:
	if is_crouching:
		return crouch_speed
	if Input.is_action_pressed("sprint"):
		return sprint_speed
	return walk_speed


## Changes the held flashlight's hue when [param event] is one of the color actions.
func _handle_hue_input(event: InputEvent) -> void:
	if event.is_action_pressed("color_next"):
		flashlight.cycle_hue(1)
	elif event.is_action_pressed("color_prev"):
		flashlight.cycle_hue(-1)


## Switches the mouse between captured for play and visible for the desktop.
func _toggle_mouse_capture() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
