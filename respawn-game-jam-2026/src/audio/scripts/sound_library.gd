class_name SoundLibrary
extends Resource
## The game's list of audio: every sound effect and every music or ambience track, each under a name.
## Scripts ask for audio by name, so the file behind a name can be swapped here without touching code.

## Sound effects by name.
@export var cues: Dictionary[StringName, SoundCue] = {}
## Music and ambience tracks by name; these loop when played.
@export var tracks: Dictionary[StringName, AudioStream] = {}


## Returns the sound effect called [param cue_name], or null if the library has none.
func find_cue(cue_name: StringName) -> SoundCue:
	return cues.get(cue_name)


## Returns the track called [param track_name], or null if the library has none.
func find_track(track_name: StringName) -> AudioStream:
	return tracks.get(track_name)
