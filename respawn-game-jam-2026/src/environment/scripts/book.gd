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

@onready var _choice: Choice = $Choice


## Puts the title in the hint and listens for the player picking the book.
func _ready() -> void:
	_choice.prompt = "Take \"%s\"" % title
	_choice.is_correct = is_correct
	_choice.chosen_right.connect(_on_choice_chosen_right)


## Announces that the right book was taken, then removes it from the shelf.
func _on_choice_chosen_right() -> void:
	taken.emit()
	queue_free()
