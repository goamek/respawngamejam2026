class_name Book
extends StaticBody3D
## Book on a shelf that the player can try to take; one of a set where only some are the right one.
## A wrong book stays on the shelf. The right one comes off it.

## Emitted when the player takes this book and it is the right one.
signal taken

## Title shown in the hint while the player aims at the book.
@export var title: String = "Untitled"
## Whether this is the book the player is looking for.
@export var is_correct: bool = false
## Name in the sound library of the sound played when the player takes hold of the book, right or wrong; leave empty for none.
@export var pickup_sound: StringName = &"pickup"

@onready var _choice: Choice = $Choice


## Puts the title in the hint and listens for the player picking the book.
func _ready() -> void:
	_choice.prompt = "Take \"%s\"" % title
	_choice.is_correct = is_correct
	_choice.chosen_right.connect(_on_choice_chosen_right)
	_choice.chosen_wrong.connect(_on_choice_chosen_wrong)


## Plays the pickup sound, announces that the right book was taken, then removes it from the shelf.
func _on_choice_chosen_right() -> void:
	AudioController.play_sound(pickup_sound)
	taken.emit()
	queue_free()


## Plays the pickup sound for a wrong book, which is pulled at and stays on the shelf.
func _on_choice_chosen_wrong() -> void:
	AudioController.play_sound(pickup_sound)
