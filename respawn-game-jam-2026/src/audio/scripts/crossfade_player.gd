class_name CrossfadePlayer
extends Node
## Plays one looping track at a time on an audio bus, fading the old track out as the new one fades in.

## Name of the audio bus the tracks play on.
@export var bus: StringName = &"Master"
## Volume a track is faded up to, from 0 for silent to 1 for as recorded.
@export var full_volume: float = 1.0

var _players: Array[AudioStreamPlayer] = []
var _fades: Array[Tween] = []
var _active_index: int = 0
var _current: AudioStream


## Creates the two players a crossfade needs: one fading out while the other fades in.
func _ready() -> void:
	for index: int in 2:
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = bus
		player.volume_linear = 0.0
		player.finished.connect(_on_player_finished.bind(player))
		add_child(player)
		_players.append(player)
		_fades.append(null)


## Fades to [param stream] over [param fade_time] seconds and loops it at [param volume] times full volume; does nothing if it is already playing.
func play(stream: AudioStream, fade_time: float, volume: float = 1.0) -> void:
	if stream == _current:
		return
	_fade(_active_index, 0.0, fade_time)
	_active_index = 1 - _active_index
	_current = stream
	var player: AudioStreamPlayer = _players[_active_index]
	player.stream = stream
	player.play()
	_fade(_active_index, full_volume * volume, fade_time)


## Fades the current track out over [param fade_time] seconds and stops it.
func stop(fade_time: float) -> void:
	_current = null
	_fade(_active_index, 0.0, fade_time)


## Returns the track that is playing or fading in, or null when there is none.
func current_stream() -> AudioStream:
	return _current


## Restarts [param player] when its track reaches the end, so tracks loop whatever their file format.
func _on_player_finished(player: AudioStreamPlayer) -> void:
	player.play()


## Moves the player at [param index] to [param volume], from 0 to 1, over [param fade_time] seconds, stopping it at zero.
func _fade(index: int, volume: float, fade_time: float) -> void:
	var player: AudioStreamPlayer = _players[index]
	if _fades[index] != null:
		_fades[index].kill()
		_fades[index] = null
	if fade_time <= 0.0:
		player.volume_linear = volume
		if volume <= 0.0:
			player.stop()
		return
	var tween: Tween = create_tween()
	tween.tween_property(player, "volume_linear", volume, fade_time)
	if volume <= 0.0:
		tween.tween_callback(player.stop)
	_fades[index] = tween
