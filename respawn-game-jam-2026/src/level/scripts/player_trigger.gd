class_name PlayerTrigger
extends Area3D
## Invisible region that reports the player walking into it.
## Give it one or more CollisionShape3D children that cover the region.

## Emitted when [param player] walks in.
signal triggered(player: Player)

## Physics layer the player's body is on: player (2).
const PLAYER_LAYER: int = 0b10

## Whether the player must be holding the flashlight for the trigger to fire.
@export var requires_flashlight: bool = false
## Whether the trigger fires only the first time, and never again.
@export var is_one_shot: bool = true

var _has_fired: bool = false


## Watches for the player's body and nothing else.
func _ready() -> void:
	collision_layer = 0
	collision_mask = PLAYER_LAYER
	body_entered.connect(_on_body_entered)


## Fires when [param body] is the player and the trigger's conditions are met.
func _on_body_entered(body: Node3D) -> void:
	var player := body as Player
	if player == null or (is_one_shot and _has_fired):
		return
	if requires_flashlight and player.flashlight == null:
		return
	_has_fired = true
	triggered.emit(player)
