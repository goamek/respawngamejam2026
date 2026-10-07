class_name Flashlight
extends Node3D
## Handheld flashlight that shines one spectrum hue at a time.
## Publishes its beam to the reveal shader so objects of the matching hue show their color.

## Emitted when the light turns on or off.
signal toggled(is_on: bool)
## Emitted when the beam changes to a different hue.
signal hue_changed(hue: Spectrum.Hue)
## Emitted when a hue becomes available to cycle to.
signal hue_unlocked(hue: Spectrum.Hue)

## Value published as the beam hue while the light is off, matching no object.
const NO_HUE: int = -1
## Physics layers the beam's lit spot can land on: world (1).
const LIT_SURFACE_MASK: int = 0b1
const _PARAM_POSITION: StringName = &"flashlight_position"
const _PARAM_DIRECTION: StringName = &"flashlight_direction"
const _PARAM_CONE_COS: StringName = &"flashlight_cone_cos"
const _PARAM_RANGE: StringName = &"flashlight_range"
const _PARAM_HUE: StringName = &"flashlight_hue"

## Hues the player can cycle through, kept in spectrum order. Leave empty for a colorless beam that reveals nothing.
@export var unlocked_hues: Array[Spectrum.Hue] = [Spectrum.Hue.RED]
## Whether the light is shining.
@export var is_on: bool = true
## Name in the sound library of the click played when the light is switched on or off; leave empty for none.
@export var switch_sound: StringName = &"flashlight_switch"

## Hue the beam shines while the light is on; colorless until the first hue is unlocked.
var current_hue: Spectrum.Hue:
	get:
		if unlocked_hues.is_empty():
			return Spectrum.Hue.NONE
		return unlocked_hues[_hue_index]

var _hue_index: int = 0

@onready var _light: SpotLight3D = $SpotLight3D


## Sorts the starting hues and shows the starting state.
func _ready() -> void:
	unlocked_hues.sort()
	_refresh_light()


## Publishes the beam to the reveal shader every frame, since the holder moves it.
func _process(_delta: float) -> void:
	_publish_beam()


## Stops revealing objects when the flashlight leaves the scene.
func _exit_tree() -> void:
	RenderingServer.global_shader_parameter_set(_PARAM_HUE, NO_HUE)


## Turns the light on if it is off, and off if it is on.
func toggle() -> void:
	is_on = not is_on
	_refresh_light()
	AudioController.play_sound(switch_sound)
	toggled.emit(is_on)


## Moves [param step] places through the unlocked hues, wrapping around at either end.
func cycle_hue(step: int) -> void:
	if unlocked_hues.size() < 2:
		return
	_hue_index = posmod(_hue_index + step, unlocked_hues.size())
	_refresh_light()
	hue_changed.emit(current_hue)


## Unlocks [param hue] and switches the beam to it; the seventh spectrum hue also unlocks white.
func unlock_hue(hue: Spectrum.Hue) -> void:
	if unlocked_hues.has(hue):
		return
	_add_hue(hue)
	if Spectrum.has_all_colors(unlocked_hues) and not unlocked_hues.has(Spectrum.Hue.WHITE):
		_add_hue(Spectrum.Hue.WHITE)
	_refresh_light()
	hue_changed.emit(current_hue)


## Whether [param point], in global space, is inside the beam's cone and range while the light is on.
func is_lighting(point: Vector3) -> bool:
	if not is_on:
		return false
	var to_point: Vector3 = point - _light.global_position
	if to_point.length() > _light.spot_range:
		return false
	return to_point.normalized().dot(_beam_direction()) >= _cone_cos()


## Returns where the center of the beam lands, as a ray hit with position and normal, or empty when off or nothing is hit.
func find_lit_spot() -> Dictionary:
	if not is_on:
		return {}
	var beam_end: Vector3 = _light.global_position + _beam_direction() * _light.spot_range
	var query := PhysicsRayQueryParameters3D.create(_light.global_position, beam_end, LIT_SURFACE_MASK)
	return get_world_3d().direct_space_state.intersect_ray(query)


## Adds [param hue] in spectrum order, selects it, and announces it.
func _add_hue(hue: Spectrum.Hue) -> void:
	unlocked_hues.append(hue)
	unlocked_hues.sort()
	_hue_index = unlocked_hues.find(hue)
	hue_unlocked.emit(hue)


## Returns the direction the beam points, in global space.
func _beam_direction() -> Vector3:
	return -_light.global_basis.z


## Returns the cosine of the beam's half angle, for comparing against dot products.
func _cone_cos() -> float:
	return cos(deg_to_rad(_light.spot_angle))


## Matches the spotlight's visibility and color to the current state.
func _refresh_light() -> void:
	_light.visible = is_on
	_light.light_color = Spectrum.color_of(current_hue)


## Sends the beam's position, direction, shape, and hue to the reveal shader.
func _publish_beam() -> void:
	RenderingServer.global_shader_parameter_set(_PARAM_POSITION, _light.global_position)
	RenderingServer.global_shader_parameter_set(_PARAM_DIRECTION, _beam_direction())
	RenderingServer.global_shader_parameter_set(_PARAM_CONE_COS, _cone_cos())
	RenderingServer.global_shader_parameter_set(_PARAM_RANGE, _light.spot_range)
	RenderingServer.global_shader_parameter_set(_PARAM_HUE, current_hue if is_on else NO_HUE)
