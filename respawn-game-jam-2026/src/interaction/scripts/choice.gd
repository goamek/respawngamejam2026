class_name Choice
extends Interactable
## One of several things the player can try, of which only some are right.
## A right one announces itself; a wrong one stays as it is and says so in the hint for a moment.

## Emitted when the player picks this and it is right.
signal chosen_right
## Emitted when the player picks this and it is wrong.
signal chosen_wrong

## Whether picking this is the right answer.
@export var is_correct: bool = false
## Hint shown for a moment after a wrong pick.
@export var wrong_prompt: String = "Not this one"
## How long the wrong hint stays up, in seconds.
@export var wrong_prompt_time: float = 1.5

var _usual_prompt: String = ""
var _is_showing_wrong: bool = false


## Announces whether [param player]'s pick was right, and shows the wrong hint if it was not.
func interact(player: Player) -> void:
	super(player)
	if is_correct:
		chosen_right.emit()
		return
	chosen_wrong.emit()
	_show_wrong_prompt()


## Swaps the hint for the wrong one, then puts the usual hint back after a pause.
func _show_wrong_prompt() -> void:
	if _is_showing_wrong:
		return
	_is_showing_wrong = true
	_usual_prompt = prompt
	prompt = wrong_prompt
	await get_tree().create_timer(wrong_prompt_time).timeout
	prompt = _usual_prompt
	_is_showing_wrong = false
