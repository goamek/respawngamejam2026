class_name SoundTest
extends Control
## Screen for auditioning the sound library: a button per sound effect, every track as music or ambience, and bus volumes.
## Not part of the game; run this scene on its own to listen to what the library holds.

# A variable, not a constant: the bus names come from an autoload, which does not exist yet when constants are worked out.
var _bus_labels: Dictionary = {
	AudioController.Bus.MASTER: "Master",
	AudioController.Bus.MUSIC: "Music",
	AudioController.Bus.AMBIENCE: "Ambience",
	AudioController.Bus.SFX: "Sound effects",
}

@onready var _sounds: GridContainer = $Margin/Columns/SoundsColumn/Scroll/Sounds
@onready var _tracks: GridContainer = $Margin/Columns/Side/Tracks
@onready var _volumes: GridContainer = $Margin/Columns/Side/Volumes
@onready var _fade_time: SpinBox = $Margin/Columns/Side/FadeRow/FadeTime
@onready var _stop_music: Button = $Margin/Columns/Side/StopRow/StopMusic
@onready var _stop_ambience: Button = $Margin/Columns/Side/StopRow/StopAmbience
@onready var _stop_sounds: Button = $Margin/Columns/Side/StopRow/StopSounds


## Frees the mouse and fills the screen from the sound library.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_stop_music.pressed.connect(_on_stop_music_pressed)
	_stop_ambience.pressed.connect(_on_stop_ambience_pressed)
	_stop_sounds.pressed.connect(_on_stop_sounds_pressed)
	var library: SoundLibrary = AudioController.library
	if library != null:
		_build_sounds(library)
		_build_tracks(library)
	_build_volumes()


## Plays the sound effect called [param cue_name].
func _on_sound_button_pressed(cue_name: StringName) -> void:
	AudioController.play_sound(cue_name)


## Fades to the track called [param track_name] as music.
func _on_music_button_pressed(track_name: StringName) -> void:
	AudioController.play_music(track_name, _fade_time.value)


## Fades to the track called [param track_name] as ambience.
func _on_ambience_button_pressed(track_name: StringName) -> void:
	AudioController.play_ambience(track_name, _fade_time.value)


## Fades the music out.
func _on_stop_music_pressed() -> void:
	AudioController.stop_music(_fade_time.value)


## Fades the ambience out.
func _on_stop_ambience_pressed() -> void:
	AudioController.stop_ambience(_fade_time.value)


## Cuts off every sound effect.
func _on_stop_sounds_pressed() -> void:
	AudioController.stop_all_sounds()


## Sets the volume of [param bus] to the slider's new [param value], from 0 to 1.
func _on_volume_slider_value_changed(value: float, bus: AudioController.Bus) -> void:
	AudioController.set_volume(bus, value)


## Adds a button for every sound effect in [param library], in name order.
func _build_sounds(library: SoundLibrary) -> void:
	var names: Array[StringName] = library.cues.keys()
	names.sort_custom(func(a: StringName, b: StringName) -> bool: return String(a) < String(b))
	for cue_name: StringName in names:
		var button: Button = Button.new()
		button.text = cue_name
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_sound_button_pressed.bind(cue_name))
		_sounds.add_child(button)


## Adds a row for every track in [param library]: its name, and buttons to play it as music or as ambience.
func _build_tracks(library: SoundLibrary) -> void:
	var names: Array[StringName] = library.tracks.keys()
	names.sort_custom(func(a: StringName, b: StringName) -> bool: return String(a) < String(b))
	for track_name: StringName in names:
		var label: Label = Label.new()
		label.text = track_name
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_tracks.add_child(label)
		var music_button: Button = Button.new()
		music_button.text = "Music"
		music_button.pressed.connect(_on_music_button_pressed.bind(track_name))
		_tracks.add_child(music_button)
		var ambience_button: Button = Button.new()
		ambience_button.text = "Ambience"
		ambience_button.pressed.connect(_on_ambience_button_pressed.bind(track_name))
		_tracks.add_child(ambience_button)


## Adds a labeled volume slider for every bus, set to the bus's current volume.
func _build_volumes() -> void:
	for bus: AudioController.Bus in _bus_labels:
		var label: Label = Label.new()
		label.text = _bus_labels[bus]
		_volumes.add_child(label)
		var slider: HSlider = HSlider.new()
		slider.max_value = 1.0
		slider.step = 0.01
		slider.value = AudioController.get_volume(bus)
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		slider.value_changed.connect(_on_volume_slider_value_changed.bind(bus))
		_volumes.add_child(slider)
