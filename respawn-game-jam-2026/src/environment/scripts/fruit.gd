class_name Fruit
extends RigidBody3D
## Piece of fruit the player can carry, dark until a beam of its own hue is on it.
## Its kind decides its shape, the hue that shows it, and the id a basket checks.

## Kinds of fruit, in the order their shapes come under the Shapes node.
enum Kind { APPLE, BANANA, PEAR, BLUEBERRIES, PLUM }

## Id each kind is known by to an item socket.
const IDS: Dictionary[Kind, StringName] = {
	Kind.APPLE: &"apple",
	Kind.BANANA: &"banana",
	Kind.PEAR: &"pear",
	Kind.BLUEBERRIES: &"blueberries",
	Kind.PLUM: &"plum",
}
## Hue of light that shows each kind in color.
const HUES: Dictionary[Kind, Spectrum.Hue] = {
	Kind.APPLE: Spectrum.Hue.RED,
	Kind.BANANA: Spectrum.Hue.YELLOW,
	Kind.PEAR: Spectrum.Hue.GREEN,
	Kind.BLUEBERRIES: Spectrum.Hue.BLUE,
	Kind.PLUM: Spectrum.Hue.INDIGO,
}

## What kind of fruit this is.
@export var kind: Kind = Kind.APPLE:
	set(value):
		kind = value
		if is_node_ready():
			_apply_kind()

@onready var _shapes: Node3D = $Shapes
@onready var _revealable: Revealable = $Revealable
@onready var _carryable: Carryable = $Carryable


## Takes on the starting kind.
func _ready() -> void:
	_apply_kind()


## Shows the shape of the current kind, and sets the hue that reveals it and its id.
func _apply_kind() -> void:
	for index: int in _shapes.get_child_count():
		(_shapes.get_child(index) as Node3D).visible = index == kind
	_revealable.hue = HUES[kind]
	_carryable.item_id = IDS[kind]
