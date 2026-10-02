class_name Door
extends Node3D
## Hinged door that swings open and closed when used.
## The player can only use it under its hue; the entity opens it regardless.

## Emitted when the door starts to open.
signal opened
## Emitted when the door starts to close.
signal closed

## Hint shown while the door is closed.
const OPEN_PROMPT: String = "Open"
## Hint shown while the door is open.
const CLOSE_PROMPT: String = "Close"

## Hue the flashlight must shine on the door before it can be used.
@export var hue: Spectrum.Hue = Spectrum.Hue.RED
## How far the door swings open, in degrees.
@export var open_angle: float = 95.0
## How long a full swing takes, in seconds.
@export var swing_time: float = 0.6

## Whether the door is open or swinging open.
var is_open: bool = false

var _swing: Tween

@onready var _hinge: Node3D = $Hinge
@onready var _revealable: Revealable = $Hinge/Panel/Revealable
@onready var _interactable: Interactable = $Hinge/Panel/Interactable


## Returns the Door that [param node] is part of, such as its panel, or null if it is not part of one.
static func find_owner(node: Node) -> Door:
	while node != null:
		if node is Door:
			return node
		node = node.get_parent()
	return null


## Passes the hue to the panel and listens for the player using the door.
func _ready() -> void:
	_revealable.hue = hue
	_interactable.prompt = OPEN_PROMPT
	_interactable.interacted.connect(_on_interacted)


## Swings the door open; [param direction] of 1 or -1 picks which way it swings.
func open(direction: float = 1.0) -> void:
	if is_open:
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
