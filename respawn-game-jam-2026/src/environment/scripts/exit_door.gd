class_name ExitDoor
extends Node3D
## Door that is not there until the flashlight turns white, then stands waiting as the way out.
## It is black until the white beam is on it, and using it while lit ends the game.

## Emitted when the door comes into being, which is the moment for its sound.
signal appeared
## Emitted when the player uses the door.
signal used

var _collision_layer: int

@onready var _body: StaticBody3D = $Body
@onready var _interactable: Interactable = $Body/Interactable


## Hides the door, and waits for the player's flashlight to turn white.
func _ready() -> void:
	_interactable.interacted.connect(_on_interacted)
	# The layer is kept on in the scene and only cleared here, so the navigation bake still routes the entity round the door.
	_collision_layer = _body.collision_layer
	visible = false
	_body.collision_layer = 0
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null:
		return
	if player.flashlight != null:
		_watch(player.flashlight)
	else:
		player.flashlight_equipped.connect(_watch, CONNECT_ONE_SHOT)


## Makes the door show up and become usable; does nothing if it already has.
func appear() -> void:
	if visible:
		return
	visible = true
	_body.collision_layer = _collision_layer
	appeared.emit()


## Appears at once if [param flashlight] is already white, otherwise when it becomes so.
func _watch(flashlight: Flashlight) -> void:
	if flashlight.unlocked_hues.has(Spectrum.Hue.WHITE):
		appear()
	else:
		flashlight.hue_unlocked.connect(_on_hue_unlocked)


## Appears when the hue just unlocked is white.
func _on_hue_unlocked(hue: Spectrum.Hue) -> void:
	if hue == Spectrum.Hue.WHITE:
		appear()


## Announces that [param _player] has used the door.
func _on_interacted(_player: Player) -> void:
	used.emit()
