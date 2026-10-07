class_name InteractionPrompt
extends Control
## Shows a crosshair dot and the hint for whatever the player can interact with.

## Interactor whose hints this displays.
@export var interactor: Interactor

@onready var _label: Label = $Label


## Clears the hint and listens for changes.
func _ready() -> void:
	_label.text = ""
	interactor.prompt_changed.connect(_on_interactor_prompt_changed)


## Shows [param text] under the crosshair.
func _on_interactor_prompt_changed(text: String) -> void:
	_label.text = text
