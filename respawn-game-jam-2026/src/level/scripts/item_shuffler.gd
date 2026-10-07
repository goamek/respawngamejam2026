class_name ItemShuffler
extends Node
## Deals one setting afresh among a set of objects each time the level loads, so each sits in a different place every run.
## The set keeps the values it was given in the scene; only which object has which changes.

## Objects to shuffle among; all must have the setting.
@export var items: Array[Node] = []
## Name of the setting to shuffle, such as kind on fruit or paint on paint jars.
@export var setting: StringName
## Whether the values are shuffled; turn off to keep the layout set in the scene, for testing.
@export var is_shuffled: bool = true


## Shuffles the setting's values across the objects.
func _ready() -> void:
	if not is_shuffled:
		return
	var values: Array = []
	for item: Node in items:
		values.append(item.get(setting))
	values.shuffle()
	for index: int in items.size():
		items[index].set(setting, values[index])
