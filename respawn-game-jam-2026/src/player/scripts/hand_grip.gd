class_name HandGrip
extends SkeletonModifier3D
## Poses one hand of a Mixamo skeleton to hold something: turns the wrist to match a marker and wraps the fingers round it.
## Add it under the skeleton after the arm's inverse kinematics, so it works on the arm's final position.

## Finger bones Mixamo gives each hand, without the side, index to little finger; each has joints 1 to 3 and an end bone 4.
const FINGERS: Array[String] = ["Index", "Middle", "Ring", "Pinky"]
## Joints of each finger and of the thumb that bend.
const JOINT_COUNT: int = 3
## Share of the little finger's extra bend that each finger takes, index to little finger.
const EXTRA_BEND_SHARE: Array[float] = [0.0, 0.0, 0.5, 1.0]
## Way the palms face in the skeleton's rest pose; Mixamo rests in a T-pose, arms out and palms down.
const REST_PALM_FACING: Vector3 = Vector3.DOWN
## How much the thumb closes down toward the palm compared with across it.
const THUMB_PALMWARD_SHARE: float = 0.5

## Which hand this poses: Left or Right, as in Mixamo's bone names.
@export var side: String = "Left"
## Marker the wrist is turned to match: the fingers point along its forward (blue arrow reversed), and the palm faces its down.
@export var grip: Node3D
## Whether the wrist is turned to match the grip; off leaves the hand in line with the forearm.
@export var is_wrist_turned: bool = true

@export_group("Fingers")
## How far each joint of the four fingers closes toward the palm, in degrees: x the knuckle, y the middle joint, z the fingertip.
@export var finger_curl: Vector3 = Vector3(50.0, 70.0, 35.0)
## Angle between neighbouring fingers at the knuckle, in degrees; it fans them apart so each reads as its own finger.
@export var finger_spread: float = 4.0
## How much further the little finger bends at the knuckle, in degrees; the ring finger takes half. The short fingers close further in a real grip.
@export var little_finger_extra: float = 8.0

@export_group("Thumb")
## How far each joint of the thumb closes across the palm, in degrees: x the base, y the middle joint, z the tip.
@export var thumb_curl: Vector3 = Vector3(20.0, 25.0, 15.0)

var _hand_bone: int = -1
var _finger_bones: Array[int] = []
var _thumb_bones: Array[int] = []
## Turn from the grip marker's axes to the hand bone's own, so that forward is the fingers and down is the palm.
var _grip_to_hand: Basis
## For each finger bone, the hinge it closes about and the hinge it fans about, in the bone's own space.
var _curl_axes: Dictionary[int, Vector3] = {}
var _spread_axes: Dictionary[int, Vector3] = {}


## Turns the wrist to the grip and bends the fingers, after the animation and the arm have been posed.
func _process_modification_with_delta(_delta: float) -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if skeleton == null or grip == null:
		return
	if _hand_bone < 0:
		_find_bones(skeleton)
	if is_wrist_turned:
		# The grip's rotation is in the world; the bone's is in the skeleton, which is scaled and turned inside the player.
		var to_skeleton: Quaternion = skeleton.global_basis.get_rotation_quaternion().inverse()
		var pose: Transform3D = skeleton.get_bone_global_pose(_hand_bone)
		var wrist := (Basis(to_skeleton * grip.global_basis.get_rotation_quaternion()) * _grip_to_hand).scaled(pose.basis.get_scale())
		skeleton.set_bone_global_pose(_hand_bone, Transform3D(wrist, pose.origin))
	else:
		# The rest rotation, so the hand carries straight on from the forearm whatever the animation does with it.
		skeleton.set_bone_pose_rotation(_hand_bone, skeleton.get_bone_rest(_hand_bone).basis.get_rotation_quaternion())
	# Fanned about the middle of the hand, so the outer fingers lean away from each other by the same amount.
	var middle_of_hand: float = (FINGERS.size() - 1) / 2.0
	for finger: int in FINGERS.size():
		var joints: Array[int] = _finger_bones.slice(finger * JOINT_COUNT, (finger + 1) * JOINT_COUNT)
		var curl: Vector3 = finger_curl + Vector3(little_finger_extra * EXTRA_BEND_SHARE[finger], 0.0, 0.0)
		_bend(skeleton, joints, curl, (middle_of_hand - finger) * finger_spread)
	_bend(skeleton, _thumb_bones, thumb_curl, 0.0)


## Looks up the hand, finger and thumb bones for this side, and works out which way each joint hinges.
func _find_bones(skeleton: Skeleton3D) -> void:
	_hand_bone = skeleton.find_bone("mixamorig_%sHand" % side)
	var hand_rest: Transform3D = skeleton.get_bone_global_rest(_hand_bone)
	var to_hand: Basis = hand_rest.basis.orthonormalized().inverse()
	var fingers: Vector3 = (to_hand * (_rest_origin(skeleton, "Middle1") - hand_rest.origin)).normalized()
	var palm: Vector3 = to_hand * REST_PALM_FACING
	palm = (palm - fingers * palm.dot(fingers)).normalized()
	_grip_to_hand = Basis(palm.cross(fingers), -palm, -fingers).inverse()
	# From the little finger's knuckle to the index finger's: the line the knuckles lie along.
	var across: Vector3 = (_rest_origin(skeleton, "Index1") - _rest_origin(skeleton, "Pinky1")).normalized()
	for finger: String in FINGERS:
		for joint: int in JOINT_COUNT:
			var bone: int = skeleton.find_bone("mixamorig_%sHand%s%d" % [side, finger, joint + 1])
			var along: Vector3 = (_rest_origin(skeleton, "%s%d" % [finger, joint + 2]) - _rest_origin(skeleton, "%s%d" % [finger, joint + 1])).normalized()
			_finger_bones.append(bone)
			_set_hinges(skeleton, bone, along, REST_PALM_FACING, across)
	for joint: int in JOINT_COUNT:
		var bone: int = skeleton.find_bone("mixamorig_%sHandThumb%d" % [side, joint + 1])
		var along: Vector3 = (_rest_origin(skeleton, "Thumb%d" % (joint + 2)) - _rest_origin(skeleton, "Thumb%d" % (joint + 1))).normalized()
		_thumb_bones.append(bone)
		# The thumb closes across the palm toward the little finger, and a little down onto it.
		_set_hinges(skeleton, bone, along, (REST_PALM_FACING * THUMB_PALMWARD_SHARE - across).normalized(), across)


## Returns where the bone of this hand called [param part], such as Index1, sits in the rest pose, in the skeleton's space.
func _rest_origin(skeleton: Skeleton3D, part: String) -> Vector3:
	return skeleton.get_bone_global_rest(skeleton.find_bone("mixamorig_%sHand%s" % [side, part])).origin


## Records the hinges of [param bone], which points [param along]: one that swings it toward [param closing], one toward [param fanning].
func _set_hinges(skeleton: Skeleton3D, bone: int, along: Vector3, closing: Vector3, fanning: Vector3) -> void:
	# Each bone of this model is twisted about its own length by a different amount, so a hinge given in the
	# bone's own space would bend every finger a different way. They are worked out from the hand's shape instead.
	# Turning about the cross product of two directions swings the first toward the second.
	var to_bone: Basis = skeleton.get_bone_global_rest(bone).basis.orthonormalized().inverse()
	_curl_axes[bone] = (to_bone * along.cross(closing)).normalized()
	_spread_axes[bone] = (to_bone * along.cross(fanning)).normalized()


## Closes the three joints in [param bones] by [param curl] degrees each, and leans the first sideways by [param spread] degrees.
func _bend(skeleton: Skeleton3D, bones: Array[int], curl: Vector3, spread: float) -> void:
	for joint: int in bones.size():
		var bone: int = bones[joint]
		var bend := Quaternion(_curl_axes[bone], deg_to_rad(curl[joint]))
		if joint == 0:
			bend = Quaternion(_spread_axes[bone], deg_to_rad(spread)) * bend
		# Measured from the open hand the skeleton rests in, not from the animated pose: each animation holds
		# the fingers its own way, and a grip added to that changes with every step.
		skeleton.set_bone_pose_rotation(bone, skeleton.get_bone_rest(bone).basis.get_rotation_quaternion() * bend)
