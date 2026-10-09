class_name TrueColors
extends Node
## Turns the colored set dressing of a level grey until the flashlight shines the matching hue on it.
## Works from lists of materials and images, so the props' own scenes are left untouched.

## Hue given to a picture of many colors, where each pixel shows under the hue nearest its own; must match true_color.gdshader.
const PICTURE_HUE: int = -2

const _SHADER: Shader = preload("res://src/flashlight/shaders/true_color.gdshader")

## Part of the level searched for colored surfaces.
@export var search_root: Node
## Each single-colored material, and the hue the flashlight must shine for its color to show.
@export var hues: Dictionary[Material, Spectrum.Hue] = {}
## Images of many colors, such as posters; each part of one shows under the hue nearest its own color.
@export var pictures: Array[Texture2D] = []
## Images where only the strongly colored paint shows, under the given hue; the rest stays grey under every beam.
@export var painted: Dictionary[Texture2D, Spectrum.Hue] = {}

## How many surfaces were given a stand-in; for checking that the lists still match the level.
var surface_count: int = 0

## Stand-in made for each listed material or picture, so that everything sharing one shares its stand-in.
var _stand_ins: Dictionary[Resource, ShaderMaterial] = {}


## Swaps the listed materials and pictures once the level's props are in place.
func _ready() -> void:
	if search_root == null:
		return
	for node: Node in search_root.find_children("*", "GeometryInstance3D", true, false):
		_swap_materials(node as GeometryInstance3D)


## Replaces everything listed that [param visual] draws with its stand-in.
func _swap_materials(visual: GeometryInstance3D) -> void:
	if visual.material_override != null:
		# An override covers every surface, so it is the only material that is drawn.
		if _is_listed(visual.material_override):
			visual.material_override = _stand_in_for(visual.material_override)
			surface_count += 1
	elif visual is SpriteBase3D:
		_swap_sprite(visual as SpriteBase3D)
	elif visual is MeshInstance3D:
		_swap_surfaces(visual as MeshInstance3D)


## Gives [param sprite] a stand-in if the image it shows is a listed picture.
func _swap_sprite(sprite: SpriteBase3D) -> void:
	var image: Texture2D = sprite.get(&"texture")
	if not pictures.has(image):
		return
	if not _stand_ins.has(image):
		# A sprite draws its image without a material of its own, so the stand-in starts from a plain matte one.
		var plain := StandardMaterial3D.new()
		plain.albedo_texture = image
		plain.metallic_specular = 0.0
		_stand_ins[image] = _make_stand_in(plain, PICTURE_HUE)
		# See-through parts of the image, such as a torn corner, are cut away; without this their hidden colors would be drawn.
		# Switched on for every sprite: an image with nothing see-through loses nothing, and a compressed texture cannot be trusted to say which it is.
		_stand_ins[image].set_shader_parameter(&"is_cut_out", true)
	sprite.material_override = _stand_ins[image]
	surface_count += 1


## Replaces each listed material on the surfaces of [param mesh] with its stand-in.
func _swap_surfaces(mesh: MeshInstance3D) -> void:
	if mesh.mesh == null:
		return
	for surface: int in mesh.mesh.get_surface_count():
		var material: Material = mesh.get_active_material(surface)
		if _is_listed(material):
			mesh.set_surface_override_material(surface, _stand_in_for(material))
			surface_count += 1


## Whether [param material] is a listed material, or shows a listed image.
func _is_listed(material: Material) -> bool:
	if hues.has(material):
		return true
	var surface := material as BaseMaterial3D
	return surface != null and (pictures.has(surface.albedo_texture) or painted.has(surface.albedo_texture))


## Returns the stand-in for the listed [param material], making it the first time it is asked for.
func _stand_in_for(material: Material) -> ShaderMaterial:
	if not _stand_ins.has(material):
		var image: Texture2D = null if hues.has(material) else (material as BaseMaterial3D).albedo_texture
		var hue: int = PICTURE_HUE
		if hues.has(material):
			hue = hues[material]
		elif painted.has(image):
			hue = painted[image]
		_stand_ins[material] = _make_stand_in(material, hue)
		_stand_ins[material].set_shader_parameter(&"is_paint_only", painted.has(image))
	return _stand_ins[material]


## Builds a material that looks like [param source] under a beam of [param hue] and grey otherwise.
func _make_stand_in(source: Material, hue: int) -> ShaderMaterial:
	var stand_in := ShaderMaterial.new()
	stand_in.shader = _SHADER
	stand_in.set_shader_parameter(&"hue", hue)
	var surface := source as BaseMaterial3D
	assert(surface != null, "TrueColors can only stand in for standard materials.")
	stand_in.set_shader_parameter(&"albedo", surface.albedo_color)
	stand_in.set_shader_parameter(&"albedo_texture", surface.albedo_texture)
	stand_in.set_shader_parameter(&"roughness", surface.roughness)
	stand_in.set_shader_parameter(&"roughness_texture", surface.roughness_texture)
	stand_in.set_shader_parameter(&"metallic", surface.metallic)
	stand_in.set_shader_parameter(&"metallic_texture", surface.metallic_texture)
	stand_in.set_shader_parameter(&"specular", surface.metallic_specular)
	stand_in.set_shader_parameter(&"has_normal_texture", surface.normal_enabled and surface.normal_texture != null)
	stand_in.set_shader_parameter(&"normal_texture", surface.normal_texture)
	stand_in.set_shader_parameter(&"normal_scale", surface.normal_scale)
	stand_in.set_shader_parameter(&"uv_scale", surface.uv1_scale)
	stand_in.set_shader_parameter(&"uv_offset", surface.uv1_offset)
	stand_in.set_shader_parameter(&"is_triplanar", surface.uv1_triplanar)
	return stand_in
