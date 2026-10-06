@tool
extends EditorScript
## Bakes the open level's navigation mesh from every solid surface in the scene, leaving doors out.
##
## Run it with File > Run in the script editor while the level is the open scene.
## The editor's own Bake button cannot leave doors out, so closed doors would seal every doorway.

# No class_name: EditorScript does not exist in exported games, so a global class would fail to load there.


## Bakes and saves the navigation mesh of the scene open in the editor.
func _run() -> void:
	var mesh: NavigationMesh = _bake(EditorInterface.get_edited_scene_root())
	if mesh == null:
		return
	if mesh.resource_path.is_empty():
		push_warning("The navigation mesh is stored inside the scene. Save the scene to keep the bake.")
		return
	var error: Error = ResourceSaver.save(mesh)
	if error != OK:
		push_error("Could not save %s (error %d)." % [mesh.resource_path, error])
		return
	print("Baked %d polygons into %s." % [mesh.get_polygon_count(), mesh.resource_path])


## Rebuilds the navigation mesh of the first region under [param level] and returns it, or null on failure.
static func _bake(level: Node) -> NavigationMesh:
	if level == null:
		push_error("Open a level scene before running the navigation baker.")
		return null
	var regions: Array[Node] = level.find_children("*", "NavigationRegion3D", true, false)
	if regions.is_empty() or (regions[0] as NavigationRegion3D).navigation_mesh == null:
		push_error("The level needs a NavigationRegion3D with a NavigationMesh.")
		return null
	var region: NavigationRegion3D = regions[0]
	var mesh: NavigationMesh = region.navigation_mesh

	# The parser only reads bodies whose layer matches the mesh's mask, so clearing a
	# moving body's layer for the length of the parse leaves it out of the bake.
	var hidden_layers: Dictionary[AnimatableBody3D, int] = {}
	for node: Node in level.find_children("*", "AnimatableBody3D", true, false):
		var body: AnimatableBody3D = node
		hidden_layers[body] = body.collision_layer
		body.collision_layer = 0
	var source := NavigationMeshSourceGeometryData3D.new()
	NavigationServer3D.parse_source_geometry_data(mesh, source, level)
	for body: AnimatableBody3D in hidden_layers:
		body.collision_layer = hidden_layers[body]

	NavigationServer3D.bake_from_source_geometry_data(mesh, source)
	region.navigation_mesh = mesh
	return mesh
