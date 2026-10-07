class_name PlayerBody
extends Node3D
## The player's own body, seen in first person: it idles, walks and crouches with the player and holds the flashlight in its left hand.
## Its head is hidden so the camera, which sits where the head is, does not look out from inside it.

## Name Mixamo gives the single clip inside every animation library.
const CLIP_NAME: StringName = &"mixamo_com"
const HEAD_BONE: StringName = &"mixamorig_Head"
const NECK_BONE: StringName = &"mixamorig_Neck"
const LEFT_UPPER_ARM_BONE: StringName = &"mixamorig_LeftArm"
const LEFT_FOREARM_BONE: StringName = &"mixamorig_LeftForeArm"
const LEFT_HAND_BONE: StringName = &"mixamorig_LeftHand"
## Scale the head bone is given to hide it; exactly zero would break the bones below it.
const HIDDEN_SCALE: Vector3 = Vector3(0.001, 0.001, 0.001)

## Player this is the body of.
@export var player: Player
## Where the left hand holds the flashlight; it moves with the player's view.
@export var grip: Node3D
## Point the left elbow bends toward, so the arm folds down and out, not through the chest.
@export var elbow_hint: Node3D
## Whether the head is hidden; leave on during play, and turn off with show_head() for a shot that shows the player.
@export var is_head_hidden: bool = true
## How far below the player's eyes the base of the neck is kept, in meters.
@export var neck_drop: float = 0.18
## How far behind the player's eyes the base of the neck is kept, in meters, so that looking down shows the chest and not the inside of the neck.
@export var neck_setback: float = 0.12

@export_group("Animation")
## How long one animation takes to fade into the next, in seconds.
@export var blend_time: float = 0.2
## How many times faster than recorded the walk plays, to keep up with the player's speed.
@export var walk_animation_speed: float = 1.8
## How many times faster than recorded the crouched walk plays.
@export var crouch_walk_animation_speed: float = 1.2

var _head_bone: int
var _neck_bone: int
var _current_animation: StringName
var _arm_ik: TwoBoneIK3D

@onready var _model: Node3D = $Model
@onready var _skeleton: Skeleton3D = $Model/Skeleton3D
@onready var _animation: AnimationPlayer = $Model/AnimationPlayer


## Finds the bones it adjusts, sets the left arm up to reach for the flashlight, and starts the idle.
func _ready() -> void:
	_head_bone = _skeleton.find_bone(HEAD_BONE)
	_neck_bone = _skeleton.find_bone(NECK_BONE)
	_animation.mixer_applied.connect(_on_animation_mixer_applied)
	_set_up_arm()
	_play(&"idle", 1.0)


## Picks the animation that matches what the player is doing, and reaches for the flashlight only while one is held.
func _process(_delta: float) -> void:
	_arm_ik.active = player.flashlight != null
	var is_moving: bool = player.is_moving()
	if player.is_crouching:
		_play(&"crouch_walk" if is_moving else &"crouch_idle", crouch_walk_animation_speed if is_moving else 1.0)
	else:
		_play(&"walk" if is_moving else &"idle", walk_animation_speed if is_moving else 1.0)


## Shows the head again, for a camera that looks at the player from outside.
func show_head() -> void:
	is_head_hidden = false


## Hides the head again, for the player's own camera.
func hide_head() -> void:
	is_head_hidden = true


## Fades into [param animation_name] at [param speed] times its recorded speed, unless it is already playing.
func _play(animation_name: StringName, speed: float) -> void:
	if animation_name == _current_animation:
		return
	_current_animation = animation_name
	_animation.play("%s/%s" % [animation_name, CLIP_NAME], blend_time, speed)


## Pins the left hand to the grip with two-bone inverse kinematics: the hand is put on the grip and the shoulder and elbow follow.
func _set_up_arm() -> void:
	_arm_ik = TwoBoneIK3D.new()
	_arm_ik.name = "LeftArmIK"
	_skeleton.add_child(_arm_ik)
	_arm_ik.setting_count = 1
	_arm_ik.set_root_bone_name(0, LEFT_UPPER_ARM_BONE)
	_arm_ik.set_middle_bone_name(0, LEFT_FOREARM_BONE)
	_arm_ik.set_end_bone_name(0, LEFT_HAND_BONE)
	_arm_ik.set_target_node(0, _arm_ik.get_path_to(grip))
	_arm_ik.set_pole_node(0, _arm_ik.get_path_to(elbow_hint))


## Adjusts the pose the animation has just written: keeps the neck under the player's eyes, and hides the head.
func _on_animation_mixer_applied() -> void:
	# Each animation holds the shoulders somewhere of its own: at a different height from the player's eyes,
	# and when crouched, leaning well forward of the feet. So the whole model is slid to keep the neck
	# just below and behind the camera, whatever the pose.
	var neck_in_model: Vector3 = _skeleton.transform * _skeleton.get_bone_global_pose(_neck_bone).origin
	var neck_offset: Vector3 = _model.transform.basis * neck_in_model
	_model.position = Vector3(0.0, player.head.position.y - neck_drop, neck_setback) - neck_offset
	# Written every frame, both ways: the animations have no scale of their own to put the head back.
	_skeleton.set_bone_pose_scale(_head_bone, HIDDEN_SCALE if is_head_hidden else Vector3.ONE)
