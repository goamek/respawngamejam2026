class_name HintTrigger
extends PlayerTrigger
## Region that shows the player a hint when they walk in, and takes it away again after a while.
## Give it one or more CollisionShape3D children that cover the region.

## Line of guidance shown on screen.
@export var hint: String = ""
## How long the hint stays up, in seconds.
@export var duration: float = 6.0

## Player the hint was shown to; null until the trigger fires.
var _player: Player
var _timer: Timer


## Listens for the player walking in, and readies the clock that takes the hint away.
func _ready() -> void:
	super()
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)
	triggered.connect(_on_triggered)


## Shows the hint to [param player] and starts counting down to its removal.
func _on_triggered(player: Player) -> void:
	if hint.is_empty():
		return
	_player = player
	player.show_hint(hint)
	_timer.start(duration)


## Removes the hint once its time is up.
func _on_timer_timeout() -> void:
	# Another hint may have taken its place meanwhile, and that one is not this trigger's to remove.
	if is_instance_valid(_player) and _player.current_hint == hint:
		_player.clear_hint()
