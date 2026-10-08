class_name PaintPalette
extends StaticBody3D
## Palette that takes two jars of paint and keeps them only if they are the two it is meant to mix.
## A wrong pair is sent back where it came from, which it announces so the level can make a noise the entity hears.

## Emitted when the palette holds its two paints.
signal mixed
## Emitted when the palette has been given any other pair.
signal mixed_wrong

## The two hues of paint this palette mixes, in either order.
@export var paints: Array[Spectrum.Hue] = [Spectrum.Hue.RED, Spectrum.Hue.YELLOW]

@export_group("Sound")
## Name in the sound library of the sound played as each jar is set down; leave empty for none.
@export var place_sound: StringName = &"place_plastic"
## Name in the sound library of the sound played when the right two paints are mixed; leave empty for none.
@export var mix_sound: StringName = &"art_wet_painting"
## Name in the sound library of the sound played when a wrong pair is thrown off; leave empty for none.
@export var reject_sound: StringName = &"door_close"

@onready var _socket: ItemSocket = $Socket


## Tells the socket which jars it takes and which two solve it, and listens to it.
func _ready() -> void:
	var accepted: Array[StringName] = []
	for hue: Spectrum.Hue in Spectrum.Hue.values():
		accepted.append(PaintJar.id_of(hue))
	var solution: Array[StringName] = []
	for hue: Spectrum.Hue in paints:
		solution.append(PaintJar.id_of(hue))
	_socket.accepted_ids = accepted
	_socket.solution_ids = solution
	_socket.item_placed.connect(_on_socket_item_placed)
	_socket.solved.connect(_on_socket_solved)
	_socket.rejected.connect(_on_socket_rejected)


## Plays the sound of a jar being set down.
func _on_socket_item_placed(_item: Carryable) -> void:
	AudioController.play_sound_at(place_sound, global_position)


## Plays the sound of the paints mixing and announces it.
func _on_socket_solved() -> void:
	AudioController.play_sound_at(mix_sound, global_position)
	mixed.emit()


## Plays the thud of a wrong pair being thrown off and announces it; the socket sends the jars back by itself.
func _on_socket_rejected() -> void:
	AudioController.play_sound_at(reject_sound, global_position)
	mixed_wrong.emit()
