class_name EntityHearing
extends RefCounted
## Passes noises on to every entity, so whatever makes one needs no reference to the entity.

## Group every listener is in.
const LISTENER_GROUP: StringName = &"entity"


## Lets every entity in [param tree] hear a noise at [param spot], in global space, that carries [param noise_range] meters.
static func make_noise(tree: SceneTree, spot: Vector3, noise_range: float) -> void:
	for node: Node in tree.get_nodes_in_group(LISTENER_GROUP):
		(node as Entity).hear(spot, noise_range)
