extends Node
## Plays all of the game's audio by name: sound effects, looping music and ambience, and the volume of each bus.
## Registered as the AudioController autoload, so music carries on across scene changes.

## Volume channels a sound can belong to.
enum Bus { MASTER, MUSIC, AMBIENCE, SFX }

## Name of each bus in the project's audio bus layout.
const BUS_NAMES: Dictionary[Bus, StringName] = {
	Bus.MASTER: &"Master",
	Bus.MUSIC: &"Music",
	Bus.AMBIENCE: &"Ambience",
	Bus.SFX: &"SFX",
}
## Sounds with no position that can play at once.
const FLAT_POOL_SIZE: int = 8
## Sounds placed in the world that can play at once.
const WORLD_POOL_SIZE: int = 12

## List of every sound effect and track the game can play.
@export var library: SoundLibrary

# Both pools are kept in the order their players were last used, oldest first.
var _flat_players: Array[AudioStreamPlayer] = []
var _world_players: Array[AudioStreamPlayer3D] = []
var _followed: Dictionary[AudioStreamPlayer3D, Node3D] = {}
var _loops: Dictionary[StringName, CrossfadePlayer] = {}
var _warned_names: Array[StringName] = []

@onready var _music: CrossfadePlayer = $Music
@onready var _ambience: CrossfadePlayer = $Ambience


## Creates the pools of players that sound effects are played through.
func _ready() -> void:
	var sfx_bus: StringName = BUS_NAMES[Bus.SFX]
	for index: int in FLAT_POOL_SIZE:
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = sfx_bus
		add_child(player)
		_flat_players.append(player)
	for index: int in WORLD_POOL_SIZE:
		var player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
		player.bus = sfx_bus
		add_child(player)
		_world_players.append(player)


## Keeps each following sound on the node it was attached to, for as long as both last.
func _process(_delta: float) -> void:
	for player: AudioStreamPlayer3D in _followed.keys():
		var target: Node3D = _followed[player]
		if not player.playing or not is_instance_valid(target):
			_followed.erase(player)
			continue
		player.global_position = target.global_position


## Plays the sound effect called [param cue_name] with no position, at the same loudness wherever the player is.
func play_sound(cue_name: StringName) -> void:
	var cue: SoundCue = _find_cue(cue_name)
	if cue == null:
		return
	var player: AudioStreamPlayer = _take_flat_player()
	player.stream = cue.stream
	player.volume_db = cue.volume_db
	player.pitch_scale = _random_pitch(cue)
	player.play()


## Plays the sound effect called [param cue_name] at [param position] in the world, in global space.
func play_sound_at(cue_name: StringName, position: Vector3) -> void:
	var cue: SoundCue = _find_cue(cue_name)
	if cue == null:
		return
	_start_world_player(cue).global_position = position


## Plays the sound effect called [param cue_name] from [param node], following it as it moves.
func play_sound_on(cue_name: StringName, node: Node3D) -> void:
	var cue: SoundCue = _find_cue(cue_name)
	if cue == null:
		return
	var player: AudioStreamPlayer3D = _start_world_player(cue)
	player.global_position = node.global_position
	_followed[player] = node


## Starts the sound effect called [param cue_name] repeating with no position until stop_loop is called; does nothing if it already is.
func play_loop(cue_name: StringName, fade_time: float = 0.05) -> void:
	var cue: SoundCue = _find_cue(cue_name)
	if cue == null:
		return
	if not _loops.has(cue_name):
		var loop: CrossfadePlayer = CrossfadePlayer.new()
		loop.bus = BUS_NAMES[Bus.SFX]
		add_child(loop)
		_loops[cue_name] = loop
	_loops[cue_name].full_volume = db_to_linear(cue.volume_db)
	_loops[cue_name].play(cue.stream, fade_time)


## Fades out the repeating sound effect called [param cue_name] over [param fade_time] seconds.
func stop_loop(cue_name: StringName, fade_time: float = 0.15) -> void:
	if _loops.has(cue_name):
		_loops[cue_name].stop(fade_time)


## Fades to the music track called [param track_name] over [param fade_time] seconds and loops it, at [param volume] times its usual loudness.
func play_music(track_name: StringName, fade_time: float = 1.0, volume: float = 1.0) -> void:
	var track: AudioStream = _find_track(track_name)
	if track != null:
		_music.play(track, fade_time, volume)


## Whether the music track called [param track_name] is the one playing or fading in.
func is_playing_music(track_name: StringName) -> bool:
	return not track_name.is_empty() and _music.current_stream() == _find_track(track_name)


## Fades the music out over [param fade_time] seconds.
func stop_music(fade_time: float = 1.0) -> void:
	_music.stop(fade_time)


## Fades to the ambience track called [param track_name] over [param fade_time] seconds and loops it.
func play_ambience(track_name: StringName, fade_time: float = 1.0) -> void:
	var track: AudioStream = _find_track(track_name)
	if track != null:
		_ambience.play(track, fade_time)


## Fades the ambience out over [param fade_time] seconds.
func stop_ambience(fade_time: float = 1.0) -> void:
	_ambience.stop(fade_time)


## Cuts off every sound effect at once, repeating ones included; music and ambience keep playing.
func stop_all_sounds() -> void:
	for loop: CrossfadePlayer in _loops.values():
		loop.stop(0.0)
	for player: AudioStreamPlayer in _flat_players:
		player.stop()
	for player: AudioStreamPlayer3D in _world_players:
		player.stop()
	_followed.clear()


## Sets the volume of [param bus] to [param amount], from 0 for silent to 1 for full.
func set_volume(bus: Bus, amount: float) -> void:
	AudioServer.set_bus_volume_linear(_bus_index(bus), clampf(amount, 0.0, 1.0))


## Returns the volume of [param bus], from 0 for silent to 1 for full.
func get_volume(bus: Bus) -> float:
	return AudioServer.get_bus_volume_linear(_bus_index(bus))


## Returns where [param bus] sits in the project's audio bus layout.
func _bus_index(bus: Bus) -> int:
	return AudioServer.get_bus_index(BUS_NAMES[bus])


## Returns the sound effect called [param cue_name], or null with a warning if it cannot be played; an empty name means no sound and no warning.
func _find_cue(cue_name: StringName) -> SoundCue:
	if cue_name.is_empty():
		return null
	var cue: SoundCue = library.find_cue(cue_name) if library != null else null
	if cue == null or cue.stream == null:
		_warn_missing("sound", cue_name)
		return null
	return cue


## Returns the track called [param track_name], or null with a warning if the library has none; an empty name means no track and no warning.
func _find_track(track_name: StringName) -> AudioStream:
	if track_name.is_empty():
		return null
	var track: AudioStream = library.find_track(track_name) if library != null else null
	if track == null:
		_warn_missing("track", track_name)
	return track


## Warns once that the library has no playable [param kind] called [param missing_name].
func _warn_missing(kind: String, missing_name: StringName) -> void:
	if _warned_names.has(missing_name):
		return
	_warned_names.append(missing_name)
	push_warning("AudioController: no %s named \"%s\" in the sound library." % [kind, missing_name])


## Returns a pitch for one play of [param cue]: 1 for as recorded, shifted by its random variation.
func _random_pitch(cue: SoundCue) -> float:
	return 1.0 + randf_range(-cue.pitch_variation, cue.pitch_variation)


## Returns a free player for a sound with no position, or the one that started longest ago if all are busy.
func _take_flat_player() -> AudioStreamPlayer:
	var taken: AudioStreamPlayer = _flat_players[0]
	for player: AudioStreamPlayer in _flat_players:
		if not player.playing:
			taken = player
			break
	_flat_players.erase(taken)
	_flat_players.append(taken)
	return taken


## Returns a free player for a sound in the world, or the one that started longest ago if all are busy.
func _take_world_player() -> AudioStreamPlayer3D:
	var taken: AudioStreamPlayer3D = _world_players[0]
	for player: AudioStreamPlayer3D in _world_players:
		if not player.playing:
			taken = player
			break
	_world_players.erase(taken)
	_world_players.append(taken)
	_followed.erase(taken)
	return taken


## Starts [param cue] on a player in the world and returns that player so it can be positioned.
func _start_world_player(cue: SoundCue) -> AudioStreamPlayer3D:
	var player: AudioStreamPlayer3D = _take_world_player()
	player.stream = cue.stream
	player.volume_db = cue.volume_db
	player.pitch_scale = _random_pitch(cue)
	player.max_distance = cue.max_distance
	player.play()
	return player
