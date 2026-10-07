class_name Door
extends Node3D
## Hinged door that swings open and closed: for the player only under its hue, unless it is plain, and for the entity always.
## A locked door stays shut, to the player and the entity alike, until something unlocks it.

## Emitted when the door starts to open.
signal opened
## Emitted when the door has finished swinging open.
signal fully_opened
## Emitted when the door starts to close.
signal closed
## Emitted when the door is slammed shut, which is the moment for its sound.
signal slammed
## Emitted when a locked door becomes usable again.
signal unlocked

## Hint shown while the door is closed.
const OPEN_PROMPT: String = "Open"
## Hint shown while the door is open.
const CLOSE_PROMPT: String = "Close"
## Hint shown on a door that never opens.
const LOCKED_PROMPT: String = "Locked"

## Hue the flashlight must shine on the door before it can be used. None makes a plain door that always opens.
@export var hue: Spectrum.Hue = Spectrum.Hue.RED
## Whether the door is locked: nobody can use it and the entity will not open it.
@export var is_locked: bool = false
## Whether the door will lock during play while the entity is about, so its routes treat the door as a wall; re-bake the navigation mesh after changing this.
@export var can_lock_during_play: bool = false
## Material a plain door wears in place of the reveal material; leave empty to keep it dark.
@export var plain_material: Material
## Material a locked door wears, so that no beam lights it up; leave empty to keep the reveal material.
@export var locked_material: Material
## How far the door swings open, in degrees.
@export var open_angle: float = 95.0
## How long a full swing takes, in seconds.
@export var swing_time: float = 0.6
## How long the door takes to slam shut, in seconds.
@export var slam_time: float = 0.12

@export_group("Sound")
## Name in the sound library of the sound played as the door starts to open; leave empty for none.
@export var open_sound: StringName = &"door_creak"
## Name in the sound library of the sound played as the door starts to swing shut; leave empty for none.
@export var close_sound: StringName = &"door_close"
## Distance from which the entity hears the player open or close the door, in meters.
@export var noise_range: float = 6.0

## Whether the door is open or swinging open.
var is_open: bool = false

var _swing: Tween
var _original_materials: Dictionary[MeshInstance3D, Array] = {}

@onready var _hinge: Node3D = $Hinge
@onready var _panel: Node3D = $Hinge/Panel
@onready var _revealable: Revealable = $Hinge/Panel/Revealable
@onready var _interactable: Interactable = $Hinge/Panel/Interactable


## Sets the door up as locked, plain, or colored, and listens for the player using it.
func _ready() -> void:
	_remember_materials()
	if is_locked:
		_become_locked()
	else:
		_become_usable()
	_interactable.interacted.connect(_on_interactable_interacted)


## Returns the Door that [param node] is part of, such as its panel, or null if it is not part of one.
static func find_owner(node: Node) -> Door:
	while node != null:
		if node is Door:
			return node
		node = node.get_parent()
	return null


## Swings the door open; [param direction] of 1 or -1 picks which way it swings.
func open(direction: float = 1.0) -> void:
	if is_open or is_locked:
		return
	is_open = true
	_interactable.prompt = CLOSE_PROMPT
	_swing_to(deg_to_rad(open_angle) * signf(direction), swing_time)
	# A swing that is cut short is discarded without finishing, so this only fires for a door that got all the way open.
	_swing.finished.connect(fully_opened.emit)
	AudioController.play_sound_at(open_sound, _panel.global_position)
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
	_swing_to(0.0, swing_time)
	AudioController.play_sound_at(close_sound, _panel.global_position)
	closed.emit()


## Slams the door shut if it is open, then locks it.
func slam_and_lock() -> void:
	if is_locked:
		return
	if is_open:
		is_open = false
		_swing_to(0.0, slam_time)
		closed.emit()
		slammed.emit()
	is_locked = true
	_become_locked()


## Makes a locked door usable again, as the plain or colored door it was set up to be.
func unlock() -> void:
	if not is_locked:
		return
	is_locked = false
	_restore_materials()
	_become_usable()
	unlocked.emit()


## Whether the door is part way through a swing.
func is_swinging() -> bool:
	return _swing != null and _swing.is_running()


## Sets the door up to open: for anyone if it is plain, otherwise only under its hue.
func _become_usable() -> void:
	_interactable.prompt = OPEN_PROMPT
	if hue == Spectrum.Hue.NONE:
		_interactable.required_reveal = null
		_dress(plain_material)
	else:
		_interactable.required_reveal = _revealable
		_revealable.hue = hue


## Shows the locked hint whatever the light, and dresses the panel in the locked material.
func _become_locked() -> void:
	_interactable.required_reveal = null
	_interactable.prompt = LOCKED_PROMPT
	_dress(locked_material)


## Puts [param material] on every surface of the panel's meshes; does nothing if it is null.
func _dress(material: Material) -> void:
	if material == null:
		return
	for mesh: MeshInstance3D in _original_materials:
		for surface: int in mesh.get_surface_override_material_count():
			mesh.set_surface_override_material(surface, material)


## Notes the material each surface of the panel starts with, so the panel can be undressed later.
func _remember_materials() -> void:
	for node: Node in _panel.find_children("*", "MeshInstance3D", true, false):
		var mesh: MeshInstance3D = node
		var materials: Array[Material] = []
		for surface: int in mesh.get_surface_override_material_count():
			materials.append(mesh.get_surface_override_material(surface))
		_original_materials[mesh] = materials


## Puts back the material each surface of the panel started with.
func _restore_materials() -> void:
	for mesh: MeshInstance3D in _original_materials:
		for surface: int in mesh.get_surface_override_material_count():
			mesh.set_surface_override_material(surface, _original_materials[mesh][surface])


## Turns the hinge to [param angle], in radians, over [param duration] seconds, replacing any swing already under way.
func _swing_to(angle: float, duration: float) -> void:
	if _swing != null:
		_swing.kill()
	_swing = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_swing.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_swing.tween_property(_hinge, "rotation:y", angle, duration)


## Returns 1 or -1 so the door swings away from [param body].
func _direction_away_from(body: Node3D) -> float:
	return 1.0 if to_local(body.global_position).z > 0.0 else -1.0


## Closes the door if it is open, otherwise opens it away from [param player]; either way the entity may hear it.
func _on_interactable_interacted(player: Player) -> void:
	if is_locked:
		return
	EntityHearing.make_noise(get_tree(), global_position, noise_range)
	if is_open:
		close()
	else:
		open_away_from(player)
