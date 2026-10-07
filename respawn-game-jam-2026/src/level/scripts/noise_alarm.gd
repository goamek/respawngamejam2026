class_name NoiseAlarm
extends Marker3D
## Spot where a noise the entity can hear is made, for a puzzle's wrong answers.
## Place it just outside a safe room's door: the entity ignores noise from inside a room it is kept out of.

## Distance from this spot within which the entity hears the noise, in meters.
@export var noise_range: float = 25.0


## Makes the noise, sending any entity in range to check this spot.
func ring() -> void:
	EntityHearing.make_noise(get_tree(), global_position, noise_range)
