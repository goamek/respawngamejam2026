class_name Scoreboard
extends Node3D
## Gym scoreboard, switched off, whose home score reads as a different digit under each hue of light.
## A row of colored dots under that score gives an order; the guest score and the clock are only dressing.

## Brightness of each dot's own glow, so the dots can be read in the dark.
const DOT_GLOW: float = 0.6

## Hues of the dots, from left to right as the player faces the board.
@export var dot_order: Array[Spectrum.Hue] = []:
	set(value):
		dot_order = value
		if is_node_ready():
			_color_dots()

## The home score; set its digits to choose what each hue of light shows.
@onready var digit: ScoreboardDigit = $Digit
@onready var _dots: Node3D = $Dots


## Colors the dots in their starting order.
func _ready() -> void:
	_color_dots()


## Gives each dot a glowing material in its hue, and hides any dot that has none.
func _color_dots() -> void:
	for index: int in _dots.get_child_count():
		var dot := _dots.get_child(index) as MeshInstance3D
		dot.visible = index < dot_order.size()
		if not dot.visible:
			continue
		var color: Color = Spectrum.color_of(dot_order[index])
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = DOT_GLOW
		dot.material_override = material
