class_name Locker
extends StaticBody3D
## Numbered locker the player can try to open; one of a row where only one is right.
## A wrong locker rattles and stays shut. The right one swings open for good.

## Emitted when the player opens this locker and it is the right one.
signal opened
## Emitted when the player tries this locker and it is a wrong one.
signal rattled

## How far a wrong locker's door shakes, in degrees.
const RATTLE_ANGLE: float = 4.0
## How long one shake of a wrong locker's door takes, in seconds.
const RATTLE_TIME: float = 0.06

## Number on the door, which also shows in the hint.
@export var number: String = "000":
	set(value):
		number = value
		if is_node_ready():
			_show_number()
## Whether this is the locker the player is looking for.
@export var is_correct: bool = false:
	set(value):
		is_correct = value
		if is_node_ready():
			_choice.is_correct = value
## How far the door swings open, in degrees.
@export var open_angle: float = 105.0
## How long the door takes to swing open, in seconds.
@export var swing_time: float = 0.5

@export_group("Sound")
## Name in the sound library of the sound played when the right locker opens; leave empty for none.
@export var open_sound: StringName = &"gym_locker_open_right"
## Name in the sound library of the sound played when a wrong locker is tried; leave empty for none.
@export var wrong_sound: StringName = &"gym_locker_open_wrong"

## Place inside the locker where something it holds should sit.
@onready var contents_spot: Marker3D = $ContentsSpot
@onready var _choice: Choice = $Choice
@onready var _hinge: Node3D = $Hinge
@onready var _plate: Note = $Hinge/NumberPlate
@onready var _front_shape: CollisionShape3D = $Front
@onready var _back_shape: CollisionShape3D = $Back


## Shows the number and listens for the player trying the door.
func _ready() -> void:
	_show_number()
	_choice.is_correct = is_correct
	_choice.chosen_right.connect(_on_choice_chosen_right)
	_choice.chosen_wrong.connect(_on_choice_chosen_wrong)


## Swings the door open for good and lets the player reach inside.
func _on_choice_chosen_right() -> void:
	AudioController.play_sound_at(open_sound, global_position)
	# The closed front is one solid shape so the whole locker can be aimed at; open, only the back stays solid.
	_front_shape.set_deferred(&"disabled", true)
	_back_shape.set_deferred(&"disabled", false)
	_choice.queue_free()
	var swing: Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	swing.tween_property(_hinge, "rotation:y", -deg_to_rad(open_angle), swing_time)
	opened.emit()


## Shakes the door against its latch and announces the wrong try.
func _on_choice_chosen_wrong() -> void:
	AudioController.play_sound_at(wrong_sound, global_position)
	var shake: Tween = create_tween()
	for turn: float in [-RATTLE_ANGLE, RATTLE_ANGLE * 0.5, -RATTLE_ANGLE * 0.5, 0.0]:
		shake.tween_property(_hinge, "rotation:y", deg_to_rad(turn), RATTLE_TIME)
	rattled.emit()


## Writes the number on the door's plate and into the hint.
func _show_number() -> void:
	_plate.text = number
	_choice.prompt = "Open locker %s" % number
