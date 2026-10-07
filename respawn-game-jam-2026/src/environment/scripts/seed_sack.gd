class_name SeedSack
extends RigidBody3D
## Sack of seeds the player can carry, named on a tag that only shows under yellow light.
## Every sack looks alike in any other light, so the tag is the only way to tell them apart.

## Plant the seeds grow into, in lowercase; it is written on the tag and is the id a plant pot checks.
@export var plant_name: String = "flower"


## Writes the plant's name on the tag and gives the sack its id, before either child reads them.
func _enter_tree() -> void:
	# Done here, not in _ready: children become ready first, and the tag takes its text as it does.
	(get_node(^"Label") as HiddenText).text = plant_name.to_upper()
	(get_node(^"Carryable") as Carryable).item_id = StringName(plant_name)
