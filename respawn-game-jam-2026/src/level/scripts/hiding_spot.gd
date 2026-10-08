class_name HidingSpot
extends Area3D
## Space under furniture where a crouched player cannot be spotted by the entity, unless it watched them get in.
## Give it one or more CollisionShape3D children that cover the space.

## Group every hiding spot joins, so the entity can find them.
const GROUP: StringName = &"hiding_spot"
## Physics layer the player's body is on: player (2).
const PLAYER_LAYER: int = 0b10


## Joins the group and watches for the player's body and nothing else.
func _ready() -> void:
	add_to_group(GROUP)
	collision_layer = 0
	collision_mask = PLAYER_LAYER


## Whether [param player] is hiding in any hiding spot in [param tree].
static func is_player_hidden(tree: SceneTree, player: Player) -> bool:
	for node: Node in tree.get_nodes_in_group(GROUP):
		if (node as HidingSpot).is_hiding(player):
			return true
	return false


## Whether [param player] is crouched inside this spot.
func is_hiding(player: Player) -> bool:
	return player.is_crouching and overlaps_body(player)
