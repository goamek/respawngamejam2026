class_name HintDisplay
extends Control
## Shows a line of guidance in the lower part of the screen, such as what to do when the entity appears.

## Player whose hints this displays.
@export var player: Player

@onready var _label: Label = $Label


## Clears the hint and listens for changes.
func _ready() -> void:
	_label.text = ""
	player.hint_changed.connect(_on_player_hint_changed)


## Shows [param text]; empty text shows nothing.
func _on_player_hint_changed(text: String) -> void:
	_label.text = text
