class_name SafeRoom
extends Area3D
## Room the entity keeps out of until its puzzle is solved.
## Give it one or more box-shaped CollisionShape3D children that together cover the room.

## Group every safe room joins, so the entity can find them.
const GROUP: StringName = &"safe_room"

## Whether the entity is still kept out.
@export var is_safe: bool = true


## Whether any safe room in [param tree] is sheltering [param point], in global space.
static func is_sheltered(tree: SceneTree, point: Vector3) -> bool:
	for node: Node in tree.get_nodes_in_group(GROUP):
		if (node as SafeRoom).shelters(point):
			return true
	return false


## Joins the group and switches off physics overlap checks, which the room does not use.
func _ready() -> void:
	add_to_group(GROUP)
	monitoring = false
	monitorable = false


## Lets the entity in from now on; connect a puzzle's solved signal to this.
func open_to_entity() -> void:
	is_safe = false


## Whether [param point], in global space, is inside the room while the entity is still kept out.
func shelters(point: Vector3) -> bool:
	if not is_safe:
		return false
	for child: Node in get_children():
		var shape := child as CollisionShape3D
		if shape == null or not shape.shape is BoxShape3D:
			continue
		var local_point: Vector3 = shape.global_transform.affine_inverse() * point
		var half_size: Vector3 = (shape.shape as BoxShape3D).size / 2.0
		if absf(local_point.x) <= half_size.x and absf(local_point.y) <= half_size.y and absf(local_point.z) <= half_size.z:
			return true
	return false
