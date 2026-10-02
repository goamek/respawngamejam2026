class_name Revealable
extends Node3D
## Gives its parent a spectrum hue that only shows under a beam of the same hue, or a white beam.
## The parent's meshes must use the reveal material; this node sets their hue and color.

const _PARAM_HUE: StringName = &"hue"
const _PARAM_COLOR: StringName = &"reveal_color"

## Hue the flashlight must shine for the parent to show its color.
@export var hue: Spectrum.Hue = Spectrum.Hue.RED:
	set(value):
		hue = value
		if is_node_ready():
			_apply_hue()


## Applies the starting hue.
func _ready() -> void:
	_apply_hue()


## Whether [param flashlight] is shining a revealing hue on this node's position.
func is_revealed_by(flashlight: Flashlight) -> bool:
	return is_revealed_at(flashlight, global_position)


## Whether [param flashlight] is shining a revealing hue on [param point], in global space.
func is_revealed_at(flashlight: Flashlight, point: Vector3) -> bool:
	return Spectrum.reveals(flashlight.current_hue, hue) and flashlight.is_lighting(point)


## Writes the hue and its color onto every mesh of the parent.
func _apply_hue() -> void:
	for mesh: GeometryInstance3D in _find_meshes():
		mesh.set_instance_shader_parameter(_PARAM_HUE, hue)
		mesh.set_instance_shader_parameter(_PARAM_COLOR, Spectrum.color_of(hue))


## Returns the parent and all of its descendants that draw geometry.
func _find_meshes() -> Array[GeometryInstance3D]:
	var meshes: Array[GeometryInstance3D] = []
	var parent: Node = get_parent()
	if parent is GeometryInstance3D:
		meshes.append(parent)
	for child: Node in parent.find_children("*", "GeometryInstance3D", true, false):
		meshes.append(child as GeometryInstance3D)
	return meshes
