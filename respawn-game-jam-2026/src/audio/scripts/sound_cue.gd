class_name SoundCue
extends Resource
## One sound effect in the sound library: the audio to play, and how loud, varied, and far-reaching it is.

## Audio to play; an AudioStreamRandomizer here picks from several variations.
@export var stream: AudioStream
## Loudness change applied to this sound, in decibels; 0 leaves it as recorded.
@export_range(-40.0, 12.0, 0.5) var volume_db: float = 0.0
## Largest random pitch change on each play, as a fraction; 0.1 means up to 10 percent higher or lower.
@export_range(0.0, 0.5, 0.01) var pitch_variation: float = 0.0
## Distance past which the sound cannot be heard when it is played in the world, in meters.
@export var max_distance: float = 20.0
