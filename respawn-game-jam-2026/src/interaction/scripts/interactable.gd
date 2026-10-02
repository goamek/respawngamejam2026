class_name Interactable
extends Node
## Makes its parent physics object something the player can aim at and use.
## Connect to the interacted signal to decide what using it does.

## Emitted when [param player] uses this object.
signal interacted(player: Player)

## Short hint shown on screen while the player aims at this object.
@export var prompt: String = "Use"
## If set, the object can only be used while the flashlight reveals the spot the player aims at.
@export var required_reveal: Revealable


## Returns the Interactable attached to [param node], or null if it has none.
static func find_on(node: Node) -> Interactable:
	for child: Node in node.get_children():
		if child is Interactable:
			return child
	return null


## Whether [param player] is able to use this object while aiming at [param aim_point], in global space.
func can_interact(player: Player, aim_point: Vector3) -> bool:
	if required_reveal == null:
		return true
	return player.flashlight != null and required_reveal.is_revealed_at(player.flashlight, aim_point)


## Uses this object on behalf of [param player].
func interact(player: Player) -> void:
	interacted.emit(player)
