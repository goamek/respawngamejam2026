class_name Crayon
extends StaticBody3D
## Collectible crayon that gives the player's flashlight a new hue when picked up.

## Emitted when a player collects this crayon.
signal collected(hue: Spectrum.Hue)

## Hint shown while the player has no flashlight to give the hue to.
const NEEDS_LIGHT_PROMPT: String = "You need a light"

## Hue the flashlight gains when this crayon is collected.
@export var hue: Spectrum.Hue = Spectrum.Hue.ORANGE
## Brightness of the crayon's own glow, so it can be found in the dark.
@export var glow: float = 0.6
## Whether the crayon is absent until appear() is called, as the reward for a puzzle.
@export var is_hidden_at_start: bool = false
## Name in the sound library of the sound played when the player picks this up; leave empty for none.
@export var pickup_sound: StringName = &"pickup"

var _collision_layer: int
var _take_prompt: String

@onready var _interactable: Interactable = $Interactable


## Colors the crayon, hides it if it is a reward, and listens for the player picking it up.
func _ready() -> void:
	_apply_color()
	_interactable.interacted.connect(_on_interactable_interacted)
	_collision_layer = collision_layer
	if is_hidden_at_start:
		visible = false
		collision_layer = 0
	_watch_for_flashlight()


## Makes a crayon that started hidden show up and become collectable.
func appear() -> void:
	visible = true
	collision_layer = _collision_layer


## Gives every mesh of the crayon a glowing material in its hue's color.
func _apply_color() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = Spectrum.color_of(hue)
	material.emission_enabled = true
	material.emission = Spectrum.color_of(hue)
	material.emission_energy_multiplier = glow
	for mesh: Node in find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material


## Swaps the hint for a pointer to the flashlight until the player in the level is holding one.
func _watch_for_flashlight() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or player.flashlight != null:
		return
	_take_prompt = _interactable.prompt
	_interactable.prompt = NEEDS_LIGHT_PROMPT
	player.flashlight_equipped.connect(_on_player_flashlight_equipped, CONNECT_ONE_SHOT)


## Puts the usual hint back once the player has a flashlight.
func _on_player_flashlight_equipped(_flashlight: Flashlight) -> void:
	_interactable.prompt = _take_prompt


## Unlocks this crayon's hue on [param player]'s flashlight, then removes the crayon.
func _on_interactable_interacted(player: Player) -> void:
	if player.flashlight == null:
		return
	player.flashlight.unlock_hue(hue)
	AudioController.play_sound(pickup_sound)
	collected.emit(hue)
	queue_free()
