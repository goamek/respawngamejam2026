class_name Revealable
extends Node3D
## Gives its parent a spectrum hue that only shows under a beam of the same hue, or a white beam.
## The parent's meshes must use the reveal material; this node sets their hue and color.

const _PARAM_HUE: StringName = &"hue"
const _PARAM_COLOR: StringName = &"reveal_color"

## Hue the flashlight must shine for the parent to show its color.
@export var hue: Spectrum.Hue = Spectrum.Hue.RED


## Applies the hue to every mesh of the parent.
func _ready() -> void:
	for mesh: GeometryInstance3D in _find_meshes():
		mesh.set_instance_shader_parameter(_PARAM_HUE, hue)
		mesh.set_instance_shader_parameter(_PARAM_COLOR, Spectrum.color_of(hue))


## Whether [param flashlight] is shining a revealing hue on this node's position.
func is_revealed_by(flashlight: Flashlight) -> bool:
	return Spectrum.reveals(flashlight.current_hue, hue) and flashlight.is_lighting(global_position)


## Returns the parent and all of its descendants that draw geometry.
func _find_meshes() -> Array[GeometryInstance3D]:
	var meshes: Array[GeometryInstance3D] = []
	var parent: Node = get_parent()
	if parent is GeometryInstance3D:
		meshes.append(parent)
	for child: Node in parent.find_children("*", "GeometryInstance3D", true, false):
		meshes.append(child as GeometryInstance3D)
	return meshes
