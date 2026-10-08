class_name PlayerBody
extends Node3D
## The player's own body, seen in first person: forearms, hands and legs, with the torso and head left undrawn.
## It idles, walks and crouches with the player, holds the flashlight in its left hand, and steadies carried objects with its right.

## Name Mixamo gives the single clip inside every animation library.
const CLIP_NAME: StringName = &"mixamo_com"
const NECK_BONE: StringName = &"mixamorig_Neck"
const HIPS_BONE: StringName = &"mixamorig_Hips"
const BODY_SHADER: Shader = preload("res://src/player/shaders/first_person_body.gdshader")
const HEAD_BONE: StringName = &"mixamorig_Head"
const HEAD_TOP_BONE: StringName = &"mixamorig_HeadTop_End"
const _PARAM_SPINE_START: StringName = &"spine_start"
const _PARAM_SPINE_END: StringName = &"spine_end"
const _PARAM_CUT_RADIUS: StringName = &"cut_radius"
const _PARAM_HEAD_CENTER: StringName = &"head_center"
const _PARAM_HEAD_RADIUS: StringName = &"head_radius"
const _PARAM_IDLE_ARM_START: StringName = &"idle_arm_start"
const _PARAM_IDLE_ARM_END: StringName = &"idle_arm_end"
const _PARAM_IDLE_ARM_RADIUS: StringName = &"idle_arm_radius"
## How far past the wrist the undrawn part of an idle arm reaches, to cover the fingers, in meters.
const HAND_LENGTH: float = 0.32
## Fraction of the arm's full length it is allowed to stretch to; a fully straight arm looks locked.
const MAX_ARM_STRETCH: float = 0.97

## Player this is the body of.
@export var player: Player
## Whether the torso and head are left undrawn; leave on during play, and turn off with show_whole_body() for a shot that shows the player.
@export var is_torso_hidden: bool = true

@export_group("Fit To Camera")
## How far below the player's eyes the base of the neck is kept, in meters.
@export var neck_drop: float = 0.18
## How far behind the player's eyes the base of the neck is kept, in meters.
@export var neck_setback: float = 0.12
## How much further back the body is slid when the player looks straight down, in meters; it puts the legs in front of the eyes, not under them.
@export var look_down_setback: float = 0.5
## Distance from the spine within which the body is not drawn, in meters; wide enough for the shoulders, narrow enough to keep the forearms.
@export var cut_radius: float = 0.26
## Distance from the middle of the head within which nothing is drawn, in meters; wide enough for the hair.
@export var head_cut_radius: float = 0.34
## How far above the hips the undrawn part starts, as a fraction of the cut radius; higher keeps more of the belly, seen when looking down.
@export_range(0.0, 2.5) var waist_margin: float = 1.6

@export_group("Left Hand")
## Where the left wrist goes to hold the flashlight; it moves with the player's view, and its rotation turns the wrist.
@export var grip: Node3D
## Point the left elbow bends toward, so the arm folds down and out, not through the chest.
@export var elbow_hint: Node3D

@export_group("Right Hand")
## Point the right elbow bends toward.
@export var right_elbow_hint: Node3D
## Where the right wrist goes relative to a carried object, in the player's view: x right, y up, z back, in meters.
@export var carry_grip_offset: Vector3 = Vector3(0.09, -0.05, 0.07)
## How the right wrist is turned while it holds a carried object, in degrees, in the player's view.
@export var carry_grip_rotation: Vector3 = Vector3(0.0, 0.0, -90.0)
## Thickness of the right arm that is left undrawn while it carries nothing, in meters; zero draws the arm, which then hangs in view when looking down.
@export var idle_arm_radius: float = 0.0

@export_group("Animation")
## How long one animation takes to fade into the next, in seconds.
@export var blend_time: float = 0.2
## How many times faster than recorded the walk plays, to keep up with the player's speed.
@export var walk_animation_speed: float = 1.8
## How many times faster than recorded the crouched walk plays.
@export var crouch_walk_animation_speed: float = 1.2

var _neck_bone: int
var _hips_bone: int
var _head_bone: int
var _head_top_bone: int
var _left_shoulder_bone: int
var _left_arm_length: float
var _right_shoulder_bone: int
var _right_forearm_bone: int
var _right_hand_bone: int
var _current_animation: StringName
var _material: ShaderMaterial
var _left_arm: TwoBoneIK3D
var _right_arm: TwoBoneIK3D
var _carry_grip: Marker3D

@onready var _model: Node3D = $Model
@onready var _skeleton: Skeleton3D = $Model/Skeleton3D
@onready var _animation: AnimationPlayer = $Model/AnimationPlayer
## Hand poses, which turn the wrists and curl the fingers; their settings are in the scene.
@onready var left_grip: HandGrip = $Model/Skeleton3D/LeftHandGrip
@onready var right_grip: HandGrip = $Model/Skeleton3D/RightHandGrip


## Dresses the mesh for first person, gives it a whole shadow, sets up both arms, and starts the idle.
func _ready() -> void:
	_neck_bone = _skeleton.find_bone(NECK_BONE)
	_hips_bone = _skeleton.find_bone(HIPS_BONE)
	_head_bone = _skeleton.find_bone(HEAD_BONE)
	_head_top_bone = _skeleton.find_bone(HEAD_TOP_BONE)
	_left_shoulder_bone = _skeleton.find_bone(&"mixamorig_LeftArm")
	_left_arm_length = _measure_arm(&"mixamorig_LeftArm", &"mixamorig_LeftForeArm", &"mixamorig_LeftHand")
	_right_shoulder_bone = _skeleton.find_bone(&"mixamorig_RightArm")
	_right_forearm_bone = _skeleton.find_bone(&"mixamorig_RightForeArm")
	_right_hand_bone = _skeleton.find_bone(&"mixamorig_RightHand")
	_dress_mesh()
	_carry_grip = Marker3D.new()
	_carry_grip.top_level = true
	add_child(_carry_grip)
	_left_arm = _add_arm("Left", grip, elbow_hint)
	_right_arm = _add_arm("Right", _carry_grip, right_elbow_hint)
	# The hand poses work on where the arms end up, so they must come after the arms under the skeleton.
	_skeleton.move_child(left_grip, -1)
	_skeleton.move_child(right_grip, -1)
	left_grip.grip = grip
	right_grip.grip = _carry_grip
	_animation.mixer_applied.connect(_on_animation_mixer_applied)
	_play(&"idle", 1.0)


## Picks the animation that matches what the player is doing, and puts each hand to work only while it has something to hold.
func _process(_delta: float) -> void:
	var is_holding_light: bool = player.flashlight != null
	_left_arm.active = is_holding_light
	left_grip.active = is_holding_light
	var carried: Carryable = player.interactor.carried
	_right_arm.active = carried != null
	right_grip.active = carried != null
	if carried != null:
		_follow_carried(carried.get_parent() as Node3D)
	var is_moving: bool = player.is_moving()
	if player.is_crouching:
		_play(&"crouch_walk" if is_moving else &"crouch_idle", crouch_walk_animation_speed if is_moving else 1.0)
	else:
		_play(&"walk" if is_moving else &"idle", walk_animation_speed if is_moving else 1.0)


## Draws the whole body, torso and head included, for a camera that looks at the player from outside.
func show_whole_body() -> void:
	is_torso_hidden = false


## Leaves the torso and head undrawn again, for the player's own camera.
func hide_torso() -> void:
	is_torso_hidden = true


## Fades into [param animation_name] at [param speed] times its recorded speed, unless it is already playing.
func _play(animation_name: StringName, speed: float) -> void:
	if animation_name == _current_animation:
		return
	_current_animation = animation_name
	_animation.play("%s/%s" % [animation_name, CLIP_NAME], blend_time, speed)


## Gives the mesh the first-person shader with the model's own textures, and adds an unseen copy that casts the whole body's shadow.
func _dress_mesh() -> void:
	var mesh := _skeleton.find_children("*", "MeshInstance3D", false, false)[0] as MeshInstance3D
	var original := mesh.mesh.surface_get_material(0) as BaseMaterial3D
	# Driven by the same skeleton, so the shadow matches the pose without animating the model twice.
	var shadow := mesh.duplicate() as MeshInstance3D
	shadow.name = "Shadow"
	shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	_skeleton.add_child(shadow)
	_material = ShaderMaterial.new()
	_material.shader = BODY_SHADER
	_material.set_shader_parameter(&"albedo_texture", original.albedo_texture)
	_material.set_shader_parameter(&"normal_texture", original.normal_texture)
	mesh.material_override = _material
	mesh.mesh = _mark_lower_arms(mesh.mesh, [_lower_arm_bones(mesh.skin, "Left"), _lower_arm_bones(mesh.skin, "Right")])
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


## Returns the first and last bone, as [param skin] numbers them, of the lower arm, hand and fingers on [param side], Left or Right.
func _lower_arm_bones(skin: Skin, side: String) -> Vector2i:
	# The mesh numbers the bones it is attached to in its own list, the skin, which is what the shader sees.
	# A bone's children come straight after it there, so everything below the elbow is one unbroken run.
	var elbow: int = _skeleton.find_bone("mixamorig_%sForeArm" % side)
	var first: int = -1
	var last: int = -1
	for bind: int in skin.get_bind_count():
		var bone: int = skin.get_bind_bone(bind)
		if bone < 0:
			bone = _skeleton.find_bone(skin.get_bind_name(bind))
		while bone > elbow:
			bone = _skeleton.get_bone_parent(bone)
		if bone == elbow:
			first = bind if first < 0 else first
			last = bind
	return Vector2i(first, last)


## Returns a copy of [param mesh] whose vertex colors say how much each point is moved by the bones in [param bone_ranges]: red 1 is wholly.
func _mark_lower_arms(mesh: Mesh, bone_ranges: Array[Vector2i]) -> ArrayMesh:
	# A shader cannot ask which bones move a point, so the answer is worked out once here and stored in the mesh.
	var source := mesh as ArrayMesh
	var marked := ArrayMesh.new()
	for blend_shape: int in source.get_blend_shape_count():
		marked.add_blend_shape(source.get_blend_shape_name(blend_shape))
	for surface: int in source.get_surface_count():
		var arrays: Array = source.surface_get_arrays(surface)
		var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
		var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
		var vertex_count: int = (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()
		# A whole number by construction: every vertex has the same count of bone slots, four or eight.
		@warning_ignore("integer_division")
		var bones_per_vertex: int = bones.size() / vertex_count
		var colors := PackedColorArray()
		colors.resize(vertex_count)
		for vertex: int in vertex_count:
			var weight: float = 0.0
			for slot: int in bones_per_vertex:
				var bone: int = bones[vertex * bones_per_vertex + slot]
				for bone_range: Vector2i in bone_ranges:
					if bone >= bone_range.x and bone <= bone_range.y:
						weight += weights[vertex * bones_per_vertex + slot]
			colors[vertex] = Color(weight, 0.0, 0.0)
		arrays[Mesh.ARRAY_COLOR] = colors
		var flags: int = source.surface_get_format(surface) & Mesh.ARRAY_FLAG_USE_8_BONE_WEIGHTS
		marked.add_surface_from_arrays(source.surface_get_primitive_type(surface), arrays, source.surface_get_blend_shape_arrays(surface), {}, flags)
		marked.surface_set_material(surface, source.surface_get_material(surface))
	return marked


## Adds two-bone inverse kinematics to the arm on [param side], Left or Right: its wrist is put on [param target] and its elbow bends toward [param hint].
func _add_arm(side: String, target: Node3D, hint: Node3D) -> TwoBoneIK3D:
	var arm := TwoBoneIK3D.new()
	arm.name = "%sArmIK" % side
	_skeleton.add_child(arm)
	arm.setting_count = 1
	arm.set_root_bone_name(0, "mixamorig_%sArm" % side)
	arm.set_middle_bone_name(0, "mixamorig_%sForeArm" % side)
	arm.set_end_bone_name(0, "mixamorig_%sHand" % side)
	arm.set_target_node(0, arm.get_path_to(target))
	arm.set_pole_node(0, arm.get_path_to(hint))
	return arm


## Keeps the right hand's grip beside [param body], the object being carried, turned to suit the player's view.
func _follow_carried(body: Node3D) -> void:
	# Taken from the object itself, not the hold point: an object held against a wall stops short of the hold point.
	var view: Basis = player.head.global_basis
	_carry_grip.global_transform = Transform3D(view * Basis.from_euler(carry_grip_rotation * (PI / 180.0)), body.global_position + view * carry_grip_offset)


## Adjusts the pose the animation has just written: keeps the neck by the camera, and tells the shader where the torso is.
func _on_animation_mixer_applied() -> void:
	# Each animation holds the shoulders somewhere of its own: at a different height from the player's eyes,
	# and when crouched, leaning well forward of the feet. So the whole model is slid to keep the neck
	# just below and behind the camera, whatever the pose.
	var neck_in_model: Vector3 = _skeleton.transform * _skeleton.get_bone_global_pose(_neck_bone).origin
	var neck_offset: Vector3 = _model.transform.basis * neck_in_model
	# Eyes are ahead of the hips, not above them: without the extra slide, looking down would look into the waist from on top.
	var look_down: float = clampf(-player.head.rotation.x / (PI / 2.0), 0.0, 1.0)
	var setback: float = neck_setback + look_down_setback * look_down
	_model.position = Vector3(0.0, player.head.position.y - neck_drop, setback) - neck_offset
	_lean_toward_grip()
	_hide_torso_and_head()
	_hide_idle_arm()


## Tells the shader where the spine and the head are in this pose, so that it leaves them undrawn.
func _hide_torso_and_head() -> void:
	_material.set_shader_parameter(_PARAM_CUT_RADIUS, cut_radius if is_torso_hidden else 0.0)
	_material.set_shader_parameter(_PARAM_HEAD_RADIUS, head_cut_radius if is_torso_hidden else 0.0)
	var to_world: Transform3D = _skeleton.global_transform
	var hips: Vector3 = to_world * _skeleton.get_bone_global_pose(_hips_bone).origin
	var neck: Vector3 = to_world * _skeleton.get_bone_global_pose(_neck_bone).origin
	var head: Vector3 = to_world * _skeleton.get_bone_global_pose(_head_bone).origin
	var head_top: Vector3 = to_world * _skeleton.get_bone_global_pose(_head_top_bone).origin
	# Started a little way up from the hips: the cut is rounded at its ends, and would otherwise take the tops of the legs.
	_material.set_shader_parameter(_PARAM_SPINE_START, hips + (neck - hips).normalized() * cut_radius * waist_margin)
	_material.set_shader_parameter(_PARAM_SPINE_END, neck)
	_material.set_shader_parameter(_PARAM_HEAD_CENTER, head.lerp(head_top, 0.5))


## Returns the length of an arm from shoulder to wrist, in meters, as the model is scaled in the level.
func _measure_arm(shoulder: StringName, elbow: StringName, wrist: StringName) -> float:
	var shoulder_at: Vector3 = _skeleton.get_bone_global_rest(_skeleton.find_bone(shoulder)).origin
	var elbow_at: Vector3 = _skeleton.get_bone_global_rest(_skeleton.find_bone(elbow)).origin
	var wrist_at: Vector3 = _skeleton.get_bone_global_rest(_skeleton.find_bone(wrist)).origin
	return (shoulder_at.distance_to(elbow_at) + elbow_at.distance_to(wrist_at)) * _skeleton.global_basis.get_scale().x


## Slides the model toward the flashlight when it is held further off than the left arm can reach, as when looking far up.
func _lean_toward_grip() -> void:
	if player.flashlight == null:
		return
	var shoulder: Vector3 = _skeleton.global_transform * _skeleton.get_bone_global_pose(_left_shoulder_bone).origin
	var to_grip: Vector3 = grip.global_position - shoulder
	var excess: float = to_grip.length() - _left_arm_length * MAX_ARM_STRETCH
	if excess > 0.0:
		# The torso is not drawn, so the lean itself is never seen; without it the hand would let go of the flashlight.
		_model.global_position += to_grip.normalized() * excess


## Tells the shader where the right arm is while it carries nothing, so that it can be left undrawn along with the torso.
func _hide_idle_arm() -> void:
	var is_idle: bool = is_torso_hidden and player.interactor.carried == null
	_material.set_shader_parameter(_PARAM_IDLE_ARM_RADIUS, idle_arm_radius if is_idle else 0.0)
	if not is_idle:
		return
	var shoulder: Vector3 = _skeleton.global_transform * _skeleton.get_bone_global_pose(_right_shoulder_bone).origin
	var forearm: Vector3 = _skeleton.global_transform * _skeleton.get_bone_global_pose(_right_forearm_bone).origin
	var hand: Vector3 = _skeleton.global_transform * _skeleton.get_bone_global_pose(_right_hand_bone).origin
	_material.set_shader_parameter(_PARAM_IDLE_ARM_START, shoulder)
	_material.set_shader_parameter(_PARAM_IDLE_ARM_END, hand + (hand - forearm).normalized() * HAND_LENGTH)
