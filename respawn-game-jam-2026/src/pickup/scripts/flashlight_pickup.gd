class_name FlashlightPickup
extends StaticBody3D
## Flashlight lying in the level, switched off, that the player picks up and keeps in their hand.
## Used when the player starts without one; it then tells them how to switch it on.

## Emitted when a player takes the flashlight.
signal collected

## Time one full fade of the glow takes, down and back up, in seconds.
const PULSE_TIME: float = 1.6
## Fraction of its full brightness the glow fades down to before it brightens again.
const DIM_FRACTION: float = 0.45

## Guidance shown on screen from the pickup until the player first switches the light; leave empty for none.
@export var hint: String = "Press F or right click to turn the flashlight on and off (RT on a controller)"
## Name in the sound library of the sound played when the player picks this up; leave empty for none.
@export var pickup_sound: StringName = &"pickup"

@onready var _interactable: Interactable = $Interactable
@onready var _flashlight: Flashlight = $Flashlight
@onready var _glow: OmniLight3D = $Glow


## Listens for the player picking it up, and starts the glow pulsing so it catches the eye.
func _ready() -> void:
	_interactable.interacted.connect(_on_interactable_interacted)
	_start_pulse()


## Hands the flashlight to [param player] with a hint on how to switch it, then removes what is left of the pickup.
func _on_interactable_interacted(player: Player) -> void:
	player.equip_flashlight(_flashlight)
	AudioController.play_sound(pickup_sound)
	if not hint.is_empty():
		player.show_hint(hint)
		# The flashlight outlives this pickup, so it is the one that takes the hint away again.
		_flashlight.toggled.connect(player.clear_hint.unbind(1), CONNECT_ONE_SHOT)
	collected.emit()
	queue_free()


## Fades the pool of light round the flashlight down and back up, over and over.
func _start_pulse() -> void:
	var full_glow: float = _glow.light_energy
	var pulse: Tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	pulse.tween_property(_glow, "light_energy", full_glow * DIM_FRACTION, PULSE_TIME / 2.0)
	pulse.tween_property(_glow, "light_energy", full_glow, PULSE_TIME / 2.0)
