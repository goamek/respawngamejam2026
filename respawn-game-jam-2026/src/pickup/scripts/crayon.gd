class_name Crayon
extends StaticBody3D
## Collectible crayon that gives the player's flashlight a new hue when picked up.

## Emitted when a player collects this crayon.
signal collected(hue: Spectrum.Hue)

## Hue the flashlight gains when this crayon is collected.
@export var hue: Spectrum.Hue = Spectrum.Hue.ORANGE
## Brightness of the crayon's own glow, so it can be found in the dark.
@export var glow: float = 0.6

@onready var _interactable: Interactable = $Interactable


## Colors the crayon and listens for the player picking it up.
func _ready() -> void:
	_apply_color()
	_interactable.interacted.connect(_on_interacted)


## Gives every mesh of the crayon a glowing material in its hue's color.
func _apply_color() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = Spectrum.color_of(hue)
	material.emission_enabled = true
	material.emission = Spectrum.color_of(hue)
	material.emission_energy_multiplier = glow
	for mesh: Node in find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material


## Unlocks this crayon's hue on [param player]'s flashlight, then removes the crayon.
func _on_interacted(player: Player) -> void:
	if player.flashlight == null:
		return
	player.flashlight.unlock_hue(hue)
	collected.emit(hue)
	queue_free()
