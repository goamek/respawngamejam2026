class_name FlashlightPickup
extends StaticBody3D
## Flashlight lying in the level, switched on, that the player picks up and keeps in their hand.
## Used when the player starts without one.

## Emitted when a player takes the flashlight.
signal collected

@onready var _interactable: Interactable = $Interactable
@onready var _flashlight: Flashlight = $Flashlight


## Listens for the player picking it up.
func _ready() -> void:
	_interactable.interacted.connect(_on_interacted)


## Hands the flashlight to [param player], then removes what is left of the pickup.
func _on_interacted(player: Player) -> void:
	player.equip_flashlight(_flashlight)
	collected.emit()
	queue_free()
