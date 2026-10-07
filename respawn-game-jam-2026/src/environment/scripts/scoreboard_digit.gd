class_name ScoreboardDigit
extends Node3D
## Seven-bar digit that reads as a different number under each hue of light, or is drawn switched off as seven dim bars.
## Every bar is split into thin stripes, one per hue, and a stripe is only drawn where that hue's digit uses the bar.

## Bars each digit lights, numbered 0 top, 1 upper right, 2 lower right, 3 bottom, 4 lower left, 5 upper left, 6 middle.
const BARS: Dictionary[int, Array] = {
	0: [0, 1, 2, 3, 4, 5],
	1: [1, 2],
	2: [0, 1, 6, 4, 3],
	3: [0, 1, 6, 2, 3],
	4: [5, 6, 1, 2],
	5: [0, 5, 6, 2, 3],
	6: [0, 5, 6, 4, 2, 3],
	7: [0, 1, 2],
	8: [0, 1, 2, 3, 4, 5, 6],
	9: [0, 1, 2, 3, 5, 6],
}
## Fraction of a stripe's share of the bar that is drawn; the rest is the gap between stripes.
const STRIPE_FILL: float = 0.8
## How far the stripes stand off the board behind them, so the two do not flicker, in meters.
const STRIPE_LIFT: float = 0.003

## Number each hue of light shows, from 0 to 9; a hue that is not listed shows nothing.
@export var digits: Dictionary[Spectrum.Hue, int] = {}:
	set(value):
		digits = value
		if is_node_ready():
			_rebuild()
## Height of the digit, in meters; it is half as wide.
@export var digit_height: float = 1.2
## Thickness of each bar, which its stripes share between them, in meters.
@export var bar_thickness: float = 0.15
## Material the stripes wear, which must be the reveal material.
@export var stripe_material: Material
## Whether the digit is drawn switched off: all seven bars, plain and dim, showing no number under any light.
@export var is_off: bool = false
## Material the bars of a switched-off digit wear.
@export var off_material: Material

var _stripe_mesh: QuadMesh = QuadMesh.new()


## Draws the starting digits.
func _ready() -> void:
	_rebuild()


## Returns the bars that [param digit] lights, or none if it is not a digit from 0 to 9.
static func bars_of(digit: int) -> Array:
	return BARS.get(digit, [])


## Replaces every stripe with the ones the current digits need.
func _rebuild() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	if is_off:
		for bar: int in bars_of(8):
			_add_bar_part(bar, 0, 1, 1.0).material_override = off_material
		return
	var hues: Array[Spectrum.Hue] = digits.keys()
	hues.sort()
	for lane: int in hues.size():
		for bar: int in bars_of(digits[hues[lane]]):
			_add_stripe(bar, lane, hues.size(), hues[lane])


## Adds the stripe of [param hue] to [param bar], in [param lane] of the [param lane_count] lanes the bar is split into.
func _add_stripe(bar: int, lane: int, lane_count: int, hue: Spectrum.Hue) -> void:
	var stripe: MeshInstance3D = _add_bar_part(bar, lane, lane_count, STRIPE_FILL)
	stripe.material_override = stripe_material
	var revealable := Revealable.new()
	revealable.hue = hue
	stripe.add_child(revealable)


## Adds and returns a flat strip along [param bar], in [param lane] of [param lane_count] lanes, filling [param fill] of that lane's width.
func _add_bar_part(bar: int, lane: int, lane_count: int, fill: float) -> MeshInstance3D:
	var half_width: float = digit_height / 4.0
	var quarter_height: float = digit_height / 4.0
	var lane_size: float = bar_thickness / lane_count
	# Lanes are counted from one edge of the bar to the other, centered on the bar's own line.
	var lane_offset: float = (lane - (lane_count - 1) / 2.0) * lane_size
	var part := MeshInstance3D.new()
	part.mesh = _stripe_mesh
	part.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if bar == 0 or bar == 3 or bar == 6:
		# Lying bars: top, bottom, and middle.
		var height: float = [2.0 * quarter_height, 0.0, 0.0, -2.0 * quarter_height, 0.0, 0.0, 0.0][bar]
		part.position = Vector3(0.0, height + lane_offset, STRIPE_LIFT)
		part.scale = Vector3(2.0 * half_width - bar_thickness, lane_size * fill, 1.0)
	else:
		# Standing bars: right side for 1 and 2, left for 4 and 5; upper half for 1 and 5.
		var side: float = half_width if bar == 1 or bar == 2 else -half_width
		var middle: float = quarter_height if bar == 1 or bar == 5 else -quarter_height
		part.position = Vector3(side + lane_offset, middle, STRIPE_LIFT)
		part.scale = Vector3(lane_size * fill, 2.0 * quarter_height - bar_thickness, 1.0)
	add_child(part)
	return part
