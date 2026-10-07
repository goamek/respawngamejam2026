class_name Interactor
extends RayCast3D
## Finds what the player is aiming at within reach, and uses, picks up, places, or drops it.
## The ray's length is the player's reach.

## Emitted when the on-screen hint should change; empty text means no hint.
signal prompt_changed(text: String)

## Hint shown while the player is carrying something.
const DROP_PROMPT: String = "Drop"
## How close to a socket's slot a carried object must be held, or the player must be aiming, for the socket to take it without being aimed at exactly, in meters.
const PLACE_NEAR_DISTANCE: float = 0.75

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


## Returns the object the player can use right now, or null; with full hands, only a socket that takes the carried item counts.
func _find_focus() -> Interactable:
	var aimed_at: Interactable = _find_under_ray()
	if aimed_at != null or carried == null:
		return aimed_at
	# Players line the carried object up with a socket, which leaves the view itself pointing past it.
	return _find_socket_near_carried()


## Returns the usable object under the ray, or null.
func _find_under_ray() -> Interactable:
	if not is_colliding():
		return null
	var interactable: Interactable = Interactable.find_on(get_collider() as Node)
	if interactable == null or (carried != null and not interactable is ItemSocket):
		return null
	if not interactable.can_interact(_player, get_collision_point()):
		return null
	return interactable


## Returns the socket nearest to where the carried object is held or to where the player is aiming, if one is close enough and takes the object, or null.
func _find_socket_near_carried() -> ItemSocket:
	var held_at: Vector3 = (carried.get_parent() as Node3D).global_position
	# With nothing under the ray, the held object's own place stands in for the aim point.
	var aimed_at: Vector3 = get_collision_point() if is_colliding() else held_at
	var nearest: ItemSocket = null
	var nearest_distance: float = PLACE_NEAR_DISTANCE
	for node: Node in get_tree().get_nodes_in_group(ItemSocket.GROUP):
		var socket: ItemSocket = node
		var distance: float = minf(socket.distance_to_slots(held_at), socket.distance_to_slots(aimed_at))
		if distance <= nearest_distance and socket.can_interact(_player, held_at):
			nearest = socket
			nearest_distance = distance
	return nearest


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
