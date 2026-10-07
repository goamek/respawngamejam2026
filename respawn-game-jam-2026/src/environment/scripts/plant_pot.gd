class_name PlantPot
extends StaticBody3D
## Pot that grows a flower once the right seeds are set in it and yellow light is held on it.
## The wrong seeds are thrown back out, which it announces so the level can make a noise the entity hears.

## Emitted when the flower has grown to full size.
signal bloomed
## Emitted when the wrong seeds are thrown out.
signal seeds_rejected

## Smallest size the flower is drawn at, as a fraction of full size; a scale of exactly zero cannot be drawn.
const MIN_SCALE: float = 0.001

@export_group("Sound")
## Name in the sound library of the sound played when the right seeds are planted; leave empty for none.
@export var plant_sound: StringName = &"greenhouse_seeds_planting"
## Name in the sound library of the sound that repeats while the flower is growing; leave empty for none.
@export var grow_sound: StringName = &"greenhouse_plant_growing"
## Name in the sound library of the sound played when the wrong seeds are thrown out; leave empty for none.
@export var reject_sound: StringName = &"door_close"

var _placed_item: Carryable
var _growth: float = 0.0

@onready var _socket: ItemSocket = $Socket
@onready var _sensor: LightSensor = $Sensor
@onready var _sprout: Node3D = $Model/Sprout


## Hides the flower and listens to the socket and the sensor.
func _ready() -> void:
	_show_growth(0.0)
	_socket.item_placed.connect(_on_socket_item_placed)
	_socket.solved.connect(_on_socket_solved)
	_socket.rejected.connect(_on_socket_rejected)
	_sensor.progress_changed.connect(_on_sensor_progress_changed)
	_sensor.charged.connect(_on_sensor_charged)


## Silences the growing sound when the level is left, since the audio controller outlives the pot.
func _exit_tree() -> void:
	AudioController.stop_loop(grow_sound)


## Remembers [param item], the thing just set in the pot.
func _on_socket_item_placed(item: Carryable) -> void:
	_placed_item = item


## Buries the seeds, and lets the light start to count.
func _on_socket_solved() -> void:
	# It stays in the pot unseen; a placed item is already out of the way of the player and their aim.
	(_placed_item.get_parent() as Node3D).hide()
	_sensor.enable()
	AudioController.play_sound_at(plant_sound, global_position)


## Plays the thud of the wrong seeds being thrown out and announces it; the socket sends them back by itself.
func _on_socket_rejected() -> void:
	AudioController.play_sound_at(reject_sound, global_position)
	seeds_rejected.emit()


## Grows or shrinks the flower to [param ratio] of full size, with the growing sound only while it gets bigger.
func _on_sensor_progress_changed(ratio: float) -> void:
	if ratio > _growth:
		AudioController.play_loop(grow_sound)
	else:
		AudioController.stop_loop(grow_sound)
	_show_growth(ratio)


## Ends the growing sound and announces the flower.
func _on_sensor_charged() -> void:
	AudioController.stop_loop(grow_sound)
	bloomed.emit()


## Draws the flower at [param ratio] of full size, and not at all at zero.
func _show_growth(ratio: float) -> void:
	_growth = ratio
	_sprout.visible = ratio > 0.0
	_sprout.scale = Vector3.ONE * maxf(ratio, MIN_SCALE)
