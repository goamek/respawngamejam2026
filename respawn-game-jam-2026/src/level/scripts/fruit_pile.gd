class_name FruitPile
extends Node
## Deals a pile of fruit afresh each time the level loads, so each kind sits in different places every run.
## The pile keeps the kinds it was given in the scene; only which piece is which changes.

## Every piece of fruit in the pile.
@export var fruits: Array[Fruit] = []
## Whether the kinds are shuffled across the pile; turn off to keep the layout set in the scene, for testing.
@export var is_shuffled: bool = true


## Shuffles the pile's kinds across its pieces.
func _ready() -> void:
	if not is_shuffled:
		return
	var kinds: Array[Fruit.Kind] = []
	for fruit: Fruit in fruits:
		kinds.append(fruit.kind)
	kinds.shuffle()
	for index: int in fruits.size():
		fruits[index].kind = kinds[index]
