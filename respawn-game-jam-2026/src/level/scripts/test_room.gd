extends Node3D
## Wires up the test room's interactive objects so each mechanic can be tried by hand.

@onready var _ceiling_light: OmniLight3D = $OmniLight3D


## Switches the ceiling light on or off when the test button is pressed.
func _on_test_button_interacted(_player: Player) -> void:
	_ceiling_light.visible = not _ceiling_light.visible
