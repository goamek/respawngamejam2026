class_name Interactor
extends RayCast3D
## Finds what the player is aiming at within reach, and uses, picks up, places, or drops it.
## The ray's length is the player's reach.

## Emitted when the on-screen hint should change; empty text means no hint.
signal prompt_changed(text: String)

## Hint shown while the player is carrying something.
const DROP_PROMPT: String = "Drop"

## Point in front of the player where a carried object is held.
@export var hold_point: Node3D

## Object the player is aiming at and able to use, or null.
var focused: Interactable
## Object the player is carrying, or null.
var carried: Carryable

var _prompt: String = ""

@onready var _player: Player = owner as Player


## Updates what the player is aiming at and the hint that goes with it.
func _physics_process(_delta: float) -> void:
	focused = _find_focus()
	_set_prompt(_current_prompt())


## Uses the focused object if there is one, otherwise drops whatever is carried.
func try_interact() -> void:
	if focused != null:
		focused.interact(_player)
	elif carried != null:
		carried.drop()


## Starts carrying [param item] at the hold point.
func carry(item: Carryable) -> void:
	carried = item
	# The item is held in the ray's path, so the ray must see past it to reach a socket.
	add_exception(item.get_parent() as CollisionObject3D)
	item.dropped.connect(_on_carried_dropped, CONNECT_ONE_SHOT)
	item.pick_up(hold_point, _player)


## Returns the usable object under the ray, or null when there is none.
## With full hands, only a socket that takes the carried item counts.
func _find_focus() -> Interactable:
	if not is_colliding():
		return null
	var interactable: Interactable = Interactable.find_on(get_collider() as Node)
	if interactable == null or (carried != null and not interactable is ItemSocket):
		return null
	if not interactable.can_interact(_player, get_collision_point()):
		return null
	return interactable


## Returns the hint for the current state: the focused object's prompt, drop, or nothing.
func _current_prompt() -> String:
	if focused != null:
		return focused.prompt
	if carried != null:
		return DROP_PROMPT
	return ""


## Stores [param text] as the hint and announces it if it changed.
func _set_prompt(text: String) -> void:
	if text == _prompt:
		return
	_prompt = text
	prompt_changed.emit(text)


## Forgets the carried object once it has been let go.
func _on_carried_dropped() -> void:
	remove_exception(carried.get_parent() as CollisionObject3D)
	carried = null
