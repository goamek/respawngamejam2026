class_name DoorLockTrigger
extends PlayerTrigger
## Region that slams a door shut and locks it when the player walks in.
## Connect a later event to unlock_door() to let the player back through.
## Place it far enough past the door that the panel does not swing shut on the player.

## Door to slam and lock.
## A path, not a node: doors live inside the school scene, which the editor's node picker cannot reach into.
@export var door_path: NodePath


## Listens for the player walking in.
func _ready() -> void:
	super()
	triggered.connect(_on_triggered)


## Unlocks the door again; does nothing if it is not locked.
func unlock_door() -> void:
	var door: Door = _find_door()
	if door != null:
		door.unlock()


## Returns the door this trigger controls, or null with a warning when the path is wrong.
func _find_door() -> Door:
	var door := get_node_or_null(door_path) as Door
	if door == null:
		push_warning("%s has no door; set its Door Path." % name)
	return door


## Slams and locks the door.
func _on_triggered(_player: Player) -> void:
	var door: Door = _find_door()
	if door != null:
		door.slam_and_lock()
