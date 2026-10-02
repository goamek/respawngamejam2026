class_name HueIndicator
extends HBoxContainer
## Shows the flashlight's unlocked hues as a row of swatches, with the current one enlarged.

## Size of the swatch for the hue the beam is shining, in pixels.
const CURRENT_SIZE: Vector2 = Vector2(36.0, 36.0)
## Size of the swatches for the other unlocked hues, in pixels.
const OTHER_SIZE: Vector2 = Vector2(22.0, 22.0)
## Opacity of the swatches for the other unlocked hues.
const OTHER_ALPHA: float = 0.35
## Opacity of the whole row while the flashlight is off.
const OFF_ALPHA: float = 0.3

## Player whose flashlight this displays.
@export var player: Player

var _flashlight: Flashlight
var _swatches: Dictionary[Spectrum.Hue, ColorRect] = {}


## Waits for the player to take hold of a flashlight.
func _ready() -> void:
	player.flashlight_equipped.connect(_on_flashlight_equipped)


## Starts following [param flashlight] and draws its hues.
func _on_flashlight_equipped(flashlight: Flashlight) -> void:
	_flashlight = flashlight
	flashlight.hue_unlocked.connect(_on_hue_unlocked)
	flashlight.hue_changed.connect(_on_hue_changed)
	flashlight.toggled.connect(_on_toggled)
	_rebuild()


## Adds a swatch when a new hue is unlocked.
func _on_hue_unlocked(_hue: Spectrum.Hue) -> void:
	_rebuild()


## Moves the highlight when the beam changes hue.
func _on_hue_changed(_hue: Spectrum.Hue) -> void:
	_refresh()


## Dims or restores the row when the light is switched.
func _on_toggled(_is_on: bool) -> void:
	_refresh()


## Replaces every swatch with one per unlocked hue, in spectrum order.
func _rebuild() -> void:
	for swatch: ColorRect in _swatches.values():
		remove_child(swatch)
		swatch.queue_free()
	_swatches.clear()
	for hue: Spectrum.Hue in _flashlight.unlocked_hues:
		var swatch := ColorRect.new()
		swatch.color = Spectrum.color_of(hue)
		swatch.size_flags_vertical = Control.SIZE_SHRINK_END
		swatch.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(swatch)
		_swatches[hue] = swatch
	_refresh()


## Enlarges the current hue's swatch, fades the others, and dims the row while the light is off.
func _refresh() -> void:
	for hue: Spectrum.Hue in _swatches:
		var is_current: bool = hue == _flashlight.current_hue
		_swatches[hue].custom_minimum_size = CURRENT_SIZE if is_current else OTHER_SIZE
		_swatches[hue].modulate.a = 1.0 if is_current else OTHER_ALPHA
	modulate.a = 1.0 if _flashlight.is_on else OFF_ALPHA
