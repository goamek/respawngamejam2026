class_name LightSensor
extends Node3D
## Spot that reacts once the flashlight has shone a revealing hue on it for long enough.
## Place it where the light must land; it needs no physics body or mesh of its own.

## Emitted while the light builds up or drains away; [param ratio] runs from 0 to 1.
signal progress_changed(ratio: float)
## Emitted once, when the light has been held on the spot for the full hold time.
signal charged

## Hue the beam must be; a white beam counts for every hue.
@export var hue: Spectrum.Hue = Spectrum.Hue.YELLOW
## How long the light must stay on the spot, in seconds. Time off the spot drains at the same rate.
@export var hold_time: float = 2.0
## Whether the sensor is counting; leave off for a step that an earlier one switches on with enable().
@export var is_enabled: bool = true

## Whether the sensor has been fully charged.
var is_charged: bool = false

var _held: float = 0.0
var _player: Player


## Builds up while the right light is on the spot, drains while it is not, and fires when full.
func _physics_process(delta: float) -> void:
	if not is_enabled or is_charged:
		return
	var held: float = clampf(_held + (delta if _is_lit() else -delta), 0.0, hold_time)
	# Compared exactly: the clamp makes an empty or full sensor repeat the same value,
	# and an approximate test would stop it just short of full.
	if held == _held:
		return
	_held = held
	progress_changed.emit(_held / hold_time)
	if _held >= hold_time:
		is_charged = true
		charged.emit()


## Starts the sensor counting.
func enable() -> void:
	is_enabled = true


## Whether the player's flashlight is shining a revealing hue on this spot right now.
func _is_lit() -> bool:
	if _player == null:
		_player = get_tree().get_first_node_in_group("player") as Player
	if _player == null or _player.flashlight == null:
		return false
	var flashlight: Flashlight = _player.flashlight
	return Spectrum.can_reveal(flashlight.current_hue, hue) and flashlight.is_lighting(global_position)
