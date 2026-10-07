class_name FruitBasket
extends StaticBody3D
## Basket that takes three pieces of fruit and keeps them only if all three are apples.
## A wrong three are sent back where they came from, which it announces so the level can make a noise the entity hears.

## Emitted when the basket holds three apples.
signal filled_right
## Emitted when the basket has been filled with anything else.
signal filled_wrong

@export_group("Sound")
## Name in the sound library of the sound played as each piece of fruit goes in; leave empty for none.
@export var place_sound: StringName = &"place_plastic"
## Name in the sound library of the sound played when a wrong three are thrown out; leave empty for none.
@export var reject_sound: StringName = &"door_close"

@onready var _socket: ItemSocket = $Socket


## Listens to the socket that holds the fruit.
func _ready() -> void:
	_socket.item_placed.connect(_on_socket_item_placed)
	_socket.solved.connect(filled_right.emit)
	_socket.rejected.connect(_on_socket_rejected)


## Plays the sound of a piece of fruit going in.
func _on_socket_item_placed(_item: Carryable) -> void:
	AudioController.play_sound_at(place_sound, global_position)


## Plays the thud of a wrong three being thrown out and announces it; the socket sends them back by itself.
func _on_socket_rejected() -> void:
	AudioController.play_sound_at(reject_sound, global_position)
	filled_wrong.emit()
