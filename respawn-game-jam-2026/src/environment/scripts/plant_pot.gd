class_name PlantPot
extends StaticBody3D
## Pot that grows a flower once the right seeds are set in it and yellow light is held on it.
## The wrong seeds are thrown back out with a noise the entity can hear.

## Emitted when the flower has grown to full size.
signal bloomed

## Smallest size the flower is drawn at, as a fraction of full size; a scale of exactly zero cannot be drawn.
const MIN_SCALE: float = 0.001

## Where the noise of wrong seeds seems to come from, such as just outside the room's door; leave empty to use the pot.
@export var alarm_spot: Node3D
## Distance from the alarm spot within which the entity hears wrong seeds being thrown out, in meters.
@export var alarm_range: float = 25.0

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
	var sack := _placed_item.get_parent() as CollisionObject3D
	sack.hide()
	# It stays in the pot unseen, so it must not block the player or anything aimed at the pot.
	sack.collision_layer = 0
	sack.collision_mask = 0
	_sensor.enable()
	AudioController.play_sound_at(plant_sound, global_position)


## Makes the noise of the wrong seeds being thrown out; the socket sends them back by itself.
func _on_socket_rejected() -> void:
	AudioController.play_sound_at(reject_sound, global_position)
	var noise_at: Vector3 = alarm_spot.global_position if alarm_spot != null else global_position
	EntityHearing.make_noise(get_tree(), noise_at, alarm_range)


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
