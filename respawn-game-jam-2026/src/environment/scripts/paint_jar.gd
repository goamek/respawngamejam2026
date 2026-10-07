class_name PaintJar
extends RigidBody3D
## Jar of paint the player can carry, dark until a beam of its paint's hue is on it.
## Every jar looks alike in any other light, so the light is the only way to tell them apart.

## Hue of the paint inside, which is the hue of light that shows it.
@export var paint: Spectrum.Hue = Spectrum.Hue.RED:
	set(value):
		paint = value
		if is_node_ready():
			_apply_paint()

@onready var _revealable: Revealable = $Revealable
@onready var _carryable: Carryable = $Carryable


## Takes on the starting paint.
func _ready() -> void:
	_apply_paint()


## Returns the id a jar of [param hue] paint is known by to an item socket.
static func id_of(hue: Spectrum.Hue) -> StringName:
	return StringName("paint_" + (Spectrum.Hue.keys()[hue] as String).to_lower())


## Sets the hue that reveals the jar and the id a palette checks.
func _apply_paint() -> void:
	_revealable.hue = paint
	_carryable.item_id = id_of(paint)
