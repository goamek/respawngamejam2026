class_name LevelMusic
extends Node
## Starts a level's music and ambience when the level loads, and fades them out when the level is left.

## Name in the sound library of the music track to loop; leave empty for none.
@export var music_track: StringName
## Name in the sound library of the ambience track to loop under the music; leave empty for none.
@export var ambience_track: StringName
## Time the tracks take to fade in and out, in seconds.
@export var fade_time: float = 2.0


## Fades in the level's tracks.
func _ready() -> void:
	AudioController.play_music(music_track, fade_time)
	AudioController.play_ambience(ambience_track, fade_time)


## Fades out the tracks this level started, since the audio controller outlives the level.
func _exit_tree() -> void:
	if not music_track.is_empty():
		AudioController.stop_music(fade_time)
	if not ambience_track.is_empty():
		AudioController.stop_ambience(fade_time)
