class_name CaughtCutscene
extends Node3D
## Short scene shown when the last life is lost: a drawing that was not there before, the camera closing in on it, and the entity's giggle.
## Place it on a wall. Whoever plays it fades the screen in after set_up() and out again after play().

## Time the camera takes to move in on the drawing, in seconds.
@export var move_time: float = 3.5
## Time the camera stays on the drawing after the giggle starts, in seconds.
@export var hold_time: float = 2.2
## Name in the sound library of the sound played as the camera settles; leave empty for none.
@export var giggle_sound: StringName = &"entity_giggle"

@onready var _picture: Sprite3D = $Picture
@onready var _light: SpotLight3D = $Light
@onready var _camera: Camera3D = $Camera
@onready var _camera_start: Marker3D = $CameraStart
@onready var _camera_end: Marker3D = $CameraEnd


## Keeps the drawing and its light out of the level until the scene plays.
func _ready() -> void:
	_picture.hide()
	_light.hide()


## Puts the drawing on the wall, lights it, and switches the view to the opening shot; call it while the screen is black.
func set_up() -> void:
	_picture.show()
	_light.show()
	_camera.global_transform = _camera_start.global_transform
	_camera.make_current()


## Moves the camera in on the drawing, plays the giggle, and returns once the shot has been held.
func play() -> void:
	var move: Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	move.tween_property(_camera, "global_transform", _camera_end.global_transform, move_time)
	await move.finished
	AudioController.play_sound(giggle_sound)
	await get_tree().create_timer(hold_time).timeout
