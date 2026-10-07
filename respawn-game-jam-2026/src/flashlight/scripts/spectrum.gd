class_name Spectrum
extends RefCounted
## The colors the flashlight can shine: the seven ROYGBIV hues, white, and the colorless beam it starts with.

# NONE is last so the first eight keep the numbers the reveal shader and saved scenes use.
enum Hue { RED, ORANGE, YELLOW, GREEN, BLUE, INDIGO, VIOLET, WHITE, NONE }

const COLORS: Dictionary[Hue, Color] = {
	Hue.RED: Color(1.0, 0.0, 0.0),
	Hue.ORANGE: Color(1.0, 0.4, 0.0),
	Hue.YELLOW: Color(1.0, 0.9, 0.0),
	Hue.GREEN: Color(0.0, 1.0, 0.1),
	Hue.BLUE: Color(0.0, 0.3, 1.0),
	Hue.INDIGO: Color(0.3, 0.0, 0.85),
	Hue.VIOLET: Color(0.75, 0.1, 1.0),
	Hue.WHITE: Color(1.0, 1.0, 1.0),
	Hue.NONE: Color(0.45, 0.45, 0.5),
}


## Returns the display color for [param hue].
static func color_of(hue: Hue) -> Color:
	return COLORS[hue]


## Whether [param hues] contains all seven spectrum colors; white and the colorless beam do not count.
static func has_all_colors(hues: Array[Hue]) -> bool:
	for hue: Hue in Hue.values():
		if hue != Hue.WHITE and hue != Hue.NONE and not hues.has(hue):
			return false
	return true


## Whether a beam of [param beam_hue] reveals an object of [param object_hue]: white reveals every hue, the colorless beam none.
static func can_reveal(beam_hue: Hue, object_hue: Hue) -> bool:
	return beam_hue == object_hue or beam_hue == Hue.WHITE
