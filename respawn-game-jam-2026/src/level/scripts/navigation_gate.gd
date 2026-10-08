class_name NavigationGate
extends Node3D
## Keeps the entity out of a box-shaped part of the level until the player's flashlight gains a hue.
## Place the node at the middle of the area. The area is cut out of the navigation mesh, so the entity plans its routes round it; once open, the entity can be sent in.

## Part of the level that holds the navigation region.
@export var environment: Node
## Player whose flashlight opens the area.
@export var player: Player
## Width, height and depth of the closed area, in meters.
@export var size: Vector3 = Vector3(10.0, 4.0, 10.0)
## Hue that opens the area once the flashlight has it.
@export var opening_hue: Spectrum.Hue = Spectrum.Hue.WHITE
## Entity sent into the area when it opens; leave empty to only open it.
@export var entity: Entity
## Patrol point inside the area: the entity heads for it when the area opens, and it joins the entity's rounds from then on.
@export var patrol_point: Node3D

## Whether the entity may walk through the area.
var is_open: bool = false

## Region holding the part of the navigation mesh inside the area; switched off while the area is closed.
var _inside_region: NavigationRegion3D


## Cuts the area out of the navigation mesh and waits for the flashlight to gain the opening hue.
func _ready() -> void:
	_split_navigation()
	player.flashlight_equipped.connect(_on_player_flashlight_equipped)
	if player.flashlight != null:
		_on_player_flashlight_equipped(player.flashlight)


## Lets the entity walk through the area from now on, and sends it to the area's patrol point.
func open() -> void:
	if is_open:
		return
	is_open = true
	_inside_region.enabled = true
	if entity == null or patrol_point == null:
		return
	entity.patrol_points.append(patrol_point)
	# The navigation map takes in the newly opened part in the background; a route asked for sooner would stop at its edge.
	await NavigationServer3D.map_changed
	# The level may have been left in the meantime; an entity that is asleep or mid-catch is left alone and finds the area on its rounds.
	if is_instance_valid(entity) and entity.is_inside_tree() and entity.can_process() and entity.state != Entity.State.CATCHING:
		entity.investigate(patrol_point.global_position)


## Moves the navigation polygons inside the area into a region of their own, which starts switched off.
func _split_navigation() -> void:
	var regions: Array[Node] = environment.find_children("*", "NavigationRegion3D", true, false)
	assert(not regions.is_empty(), "NavigationGate needs an environment with a navigation region.")
	var region: NavigationRegion3D = regions[0]
	var whole: NavigationMesh = region.navigation_mesh
	var vertices: PackedVector3Array = whole.get_vertices()
	# Copies, so the mesh file shared by every load of the level is left as it was baked.
	var outside: NavigationMesh = whole.duplicate()
	var inside: NavigationMesh = whole.duplicate()
	outside.clear_polygons()
	inside.clear_polygons()
	for index: int in whole.get_polygon_count():
		var polygon: PackedInt32Array = whole.get_polygon(index)
		var center := Vector3.ZERO
		for vertex: int in polygon:
			center += vertices[vertex]
		center /= polygon.size()
		if _contains(region.global_transform * center):
			inside.add_polygon(polygon)
		else:
			outside.add_polygon(polygon)
	region.navigation_mesh = outside
	_inside_region = NavigationRegion3D.new()
	_inside_region.navigation_mesh = inside
	_inside_region.enabled = false
	add_child(_inside_region)
	# The two halves share their edge vertices, so they join up again once both are switched on.
	_inside_region.global_transform = region.global_transform


## Whether [param point], in global space, is inside the area.
func _contains(point: Vector3) -> bool:
	var local_point: Vector3 = global_transform.affine_inverse() * point
	var half_size: Vector3 = size / 2.0
	return absf(local_point.x) <= half_size.x and absf(local_point.y) <= half_size.y and absf(local_point.z) <= half_size.z


## Opens the area if [param flashlight] already has the opening hue, or watches for it.
func _on_player_flashlight_equipped(flashlight: Flashlight) -> void:
	if flashlight.unlocked_hues.has(opening_hue):
		open()
	elif not flashlight.hue_unlocked.is_connected(_on_flashlight_hue_unlocked):
		flashlight.hue_unlocked.connect(_on_flashlight_hue_unlocked)


## Opens the area when the flashlight gains the opening hue.
func _on_flashlight_hue_unlocked(hue: Spectrum.Hue) -> void:
	if hue == opening_hue:
		open()
