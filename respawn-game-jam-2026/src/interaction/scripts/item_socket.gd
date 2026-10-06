class_name ItemSocket
extends Interactable
## Spot on its parent physics object where the player sets down carried items, one per slot.
## Once every slot is full it keeps a right answer for good and sends a wrong one back where it came from.

## Emitted each time [param item] is set down in a slot.
signal item_placed(item: Carryable)
## Emitted when the slots are full of the right items; they stay put from then on.
signal solved
## Emitted when the slots are full of the wrong items, just before they are sent back.
signal rejected

## Places the items sit, filled in order; the number of slots is how many items the socket holds.
@export var slots: Array[Node3D] = []
## Item ids that can be set down here; leave empty to take any carried item.
@export var accepted_ids: Array[StringName] = []
## Item ids that must fill the slots, in any order, to count as solved; leave empty to accept whatever fits.
@export var solution_ids: Array[StringName] = []
## Time a wrong set of items stays in the slots before being sent back, in seconds.
@export var reject_delay: float = 0.8

## Whether the socket holds its right answer.
var is_solved: bool = false

var _placed: Array[Carryable] = []


## Sets the default hint.
func _init() -> void:
	prompt = "Place"


## Checks the socket has slots, and as many as its solution needs.
func _ready() -> void:
	assert(not slots.is_empty(), "ItemSocket needs at least one slot.")
	assert(solution_ids.is_empty() or solution_ids.size() == slots.size(), "ItemSocket needs one slot per solution item.")


## Whether [param player] is carrying something that can be set down here right now.
func can_interact(player: Player, aim_point: Vector3) -> bool:
	var item: Carryable = player.interactor.carried
	if is_solved or item == null or _placed.size() >= slots.size() or not accepts(item):
		return false
	return super(player, aim_point)


## Takes the item [param player] is carrying into the next free slot.
func interact(player: Player) -> void:
	var item: Carryable = player.interactor.carried
	if item == null:
		return
	item.place_at(slots[_placed.size()])
	_placed.append(item)
	super(player)
	item_placed.emit(item)
	if _placed.size() == slots.size():
		_judge()


## Whether [param item] is a kind this socket takes.
func accepts(item: Carryable) -> bool:
	return accepted_ids.is_empty() or accepted_ids.has(item.item_id)


## Keeps a full set of right items, or announces a wrong set and sends it back after a pause.
func _judge() -> void:
	if _holds_solution():
		is_solved = true
		solved.emit()
		return
	rejected.emit()
	await get_tree().create_timer(reject_delay).timeout
	for item: Carryable in _placed:
		item.return_home()
	_placed.clear()


## Whether the placed items match the solution, in any order.
func _holds_solution() -> bool:
	if solution_ids.is_empty():
		return true
	var placed_ids: Array[StringName] = []
	for item: Carryable in _placed:
		placed_ids.append(item.item_id)
	var wanted_ids: Array[StringName] = solution_ids.duplicate()
	placed_ids.sort()
	wanted_ids.sort()
	return placed_ids == wanted_ids
