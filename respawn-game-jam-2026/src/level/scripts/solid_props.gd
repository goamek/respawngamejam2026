@tool
class_name SolidProps
extends Node3D
## Makes the set dressing in a level solid: gives each prop found by name an unseen box the size of what is drawn.
## The props' own scenes are left untouched, and a prop that shares its place with one of the level's own solid objects is skipped.

## Physics layer of the world, which the player, the enemy and carried objects all collide with.
const WORLD_LAYER: int = 1
## Thinnest a box is allowed to be on any side, in meters; a flat prop would otherwise make a box with no thickness.
const MIN_BOX_SIDE: float = 0.02

## Part of the level searched for props.
@export var environment: Node3D
## Beginnings of the names of the nodes to make solid, such as SM_Bookshelf for SM_Bookshelf, SM_Bookshelf2 and SM_Bookshelf_03.
@export var name_prefixes: PackedStringArray = [
	"SM_Bookshelf",
	"SM_Broken_Bookshelf",
	"SM_Table",
	"SM_School_Desk",
	"SM_Locker",
	"SM_Chalkboard",
	"SM_Rolling_Board",
	"SM_Drinking_Fountain",
	"SM_Pot",
	"SM_Sack",
	"SM_Paint_Easel",
]

## Exact names of props to leave walk-through, for ones that stand where the player has to stand or pass.
@export var left_open: PackedStringArray = []

## How many props were made solid; for checking that the names still match the level.
var box_count: int = 0

## Where the level's own solid objects stand: everything with collision outside the environment and outside this node.
var _occupied_spots: PackedVector3Array = []


## Builds the boxes once the level's props are in place.
func _ready() -> void:
	# Also run in the editor (this is a tool script), so that a navigation bake done there walks the enemy round the props.
	if environment == null:
		return
	_note_occupied_spots(environment.get_parent())
	_make_solid(environment)


## Records where each physics body of the level under [param level] stands, leaving out the environment's and this node's own.
func _note_occupied_spots(level: Node) -> void:
	for node: Node in level.find_children("*", "PhysicsBody3D", true, false):
		if environment.is_ancestor_of(node) or is_ancestor_of(node):
			continue
		_occupied_spots.append((node as PhysicsBody3D).global_position)


## Gives every prop under [param node] whose name matches a box, without looking inside a prop once it is found.
func _make_solid(node: Node) -> void:
	for child: Node in node.get_children():
		if child is Node3D and _is_prop(child.name):
			# A hidden prop has been taken out of the level, usually to make room for a working copy of it.
			if (child as Node3D).visible and not left_open.has(child.name):
				_add_box(child)
		else:
			_make_solid(child)


## Whether [param node_name] begins with one of the prefixes.
func _is_prop(node_name: String) -> bool:
	for prefix: String in name_prefixes:
		if node_name.begins_with(prefix):
			return true
	return false


## Adds a box that encloses everything drawn under [param prop], turned the way the prop is turned.
func _add_box(prop: Node3D) -> void:
	# Measured in a frame that is turned with the prop but not scaled: props are stretched unevenly to fit
	# the level, and physics shapes do not take uneven scale well.
	var frame := Transform3D(prop.global_basis.orthonormalized(), prop.global_position)
	var to_frame: Transform3D = frame.affine_inverse()
	var bounds := AABB()
	var has_bounds: bool = false
	var meshes: Array[Node] = prop.find_children("*", "MeshInstance3D", true, false)
	if prop is MeshInstance3D:
		meshes.append(prop)
	for node: Node in meshes:
		var mesh: MeshInstance3D = node
		var mesh_bounds: AABB = (to_frame * mesh.global_transform) * mesh.get_aabb()
		bounds = bounds.merge(mesh_bounds) if has_bounds else mesh_bounds
		has_bounds = true
	if not has_bounds:
		return
	# A puzzle piece placed inside a prop, such as a locker that opens standing in a row of lockers, has to stay
	# reachable: a box round the prop would stop the player's aim before it got there.
	for spot: Vector3 in _occupied_spots:
		if bounds.has_point(to_frame * spot):
			return
	var box := BoxShape3D.new()
	box.size = bounds.size.max(Vector3.ONE * MIN_BOX_SIDE)
	var shape := CollisionShape3D.new()
	shape.shape = box
	var body := StaticBody3D.new()
	body.name = "%sBox" % prop.name
	body.collision_layer = WORLD_LAYER
	body.collision_mask = 0
	body.add_child(shape)
	# Not given an owner, so the boxes are rebuilt each time and never saved into the level file.
	add_child(body)
	body.global_transform = frame * Transform3D(Basis.IDENTITY, bounds.get_center())
	box_count += 1
