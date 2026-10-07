class_name Door
extends Node3D
## Hinged door that swings open and closed when used.
## The player can only use it under its hue, unless it is a plain door; the entity opens it regardless.
## A locked door is shut for good, to the player and the entity alike.

## Emitted when the door starts to open.
signal opened
## Emitted when the door starts to close.
signal closed

## Hint shown while the door is closed.
const OPEN_PROMPT: String = "Open"
## Hint shown while the door is open.
const CLOSE_PROMPT: String = "Close"
## Hint shown on a door that never opens.
const LOCKED_PROMPT: String = "Locked"

## Hue the flashlight must shine on the door before it can be used. None makes a plain door that always opens.
@export var hue: Spectrum.Hue = Spectrum.Hue.RED
## Whether the door is shut for good: nobody can use it and the entity will not open it.
@export var is_locked: bool = false
## Material a plain door wears in place of the reveal material; leave empty to keep it dark.
@export var plain_material: Material
## Material a locked door wears, so that no beam lights it up; leave empty to keep the reveal material.
@export var locked_material: Material
## How far the door swings open, in degrees.
@export var open_angle: float = 95.0
## How long a full swing takes, in seconds.
@export var swing_time: float = 0.6

## Whether the door is open or swinging open.
var is_open: bool = false

var _swing: Tween

@onready var _hinge: Node3D = $Hinge
@onready var _panel: Node3D = $Hinge/Panel
@onready var _revealable: Revealable = $Hinge/Panel/Revealable
@onready var _interactable: Interactable = $Hinge/Panel/Interactable


## Returns the Door that [param node] is part of, such as its panel, or null if it is not part of one.
static func find_owner(node: Node) -> Door:
	while node != null:
		if node is Door:
			return node
		node = node.get_parent()
	return null


## Sets the door up as locked, plain, or colored, and listens for the player using it.
func _ready() -> void:
	if is_locked:
		_become_locked()
	elif hue == Spectrum.Hue.NONE:
		_become_plain()
	else:
		_revealable.hue = hue
		_interactable.prompt = OPEN_PROMPT
	_interactable.interacted.connect(_on_interacted)


## Swings the door open; [param direction] of 1 or -1 picks which way it swings.
func open(direction: float = 1.0) -> void:
	if is_open or is_locked:
		return
	is_open = true
	_interactable.prompt = CLOSE_PROMPT
	_swing_to(deg_to_rad(open_angle) * signf(direction))
	opened.emit()


## Swings the door open on the side away from [param body], so it does not swing into them.
func open_away_from(body: Node3D) -> void:
	open(_direction_away_from(body))


## Swings the door shut.
func close() -> void:
	if not is_open:
		return
	is_open = false
	_interactable.prompt = OPEN_PROMPT
	_swing_to(0.0)
	closed.emit()


## Whether the door is part way through a swing.
func is_swinging() -> bool:
	return _swing != null and _swing.is_running()


## Drops the need for light, and dresses the panel in the plain material.
func _become_plain() -> void:
	_interactable.required_reveal = null
	_interactable.prompt = OPEN_PROMPT
	_dress(plain_material)


## Shows the locked hint whatever the light, and dresses the panel in the locked material.
func _become_locked() -> void:
	_interactable.required_reveal = null
	_interactable.prompt = LOCKED_PROMPT
	_dress(locked_material)


## Puts [param material] on every surface of the panel's meshes; does nothing if it is null.
func _dress(material: Material) -> void:
	if material == null:
		return
	for node: Node in _panel.find_children("*", "MeshInstance3D", true, false):
		var mesh: MeshInstance3D = node
		for surface: int in mesh.get_surface_override_material_count():
			mesh.set_surface_override_material(surface, material)


## Turns the hinge to [param angle], in radians, replacing any swing already under way.
func _swing_to(angle: float) -> void:
	if _swing != null:
		_swing.kill()
	_swing = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_swing.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_swing.tween_property(_hinge, "rotation:y", angle, swing_time)


## Returns 1 or -1 so the door swings away from [param body].
func _direction_away_from(body: Node3D) -> float:
	return 1.0 if to_local(body.global_position).z > 0.0 else -1.0


## Closes the door if it is open, otherwise opens it away from [param player].
func _on_interacted(player: Player) -> void:
	if is_open:
		close()
	else:
		open_away_from(player)
