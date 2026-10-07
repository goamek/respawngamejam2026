class_name GymPuzzle
extends Node
## Deals the gym puzzle a fresh answer each time the level loads: the scoreboard's digits, the order of its dots, and which locker is right.
## The six lockers carry every arrangement of the three digits, so the order matters as much as the digits.

## Hues the scoreboard's digit can be read under.
const HUES: Array[Spectrum.Hue] = [Spectrum.Hue.YELLOW, Spectrum.Hue.GREEN, Spectrum.Hue.INDIGO]

## Scoreboard that shows the digits and the order.
@export var scoreboard: Scoreboard
## The six lockers, in any order.
@export var lockers: Array[Locker] = []
## Crayon the right locker holds; it should be hidden at start.
@export var crayon: Crayon
## Alarm that rings when a wrong locker is tried; leave empty for none.
@export var alarm: NoiseAlarm
## Locker number to use every time, as three different digits, for testing; leave empty to deal one at random.
@export var fixed_answer: String = ""

## Number of the right locker in this run.
var answer: String = ""


## Deals the answer and sets up the scoreboard, the lockers, and the crayon to match.
func _ready() -> void:
	assert(lockers.size() == 6, "GymPuzzle needs six lockers, one for each order of three digits.")
	var numerals: Array[int] = _deal_numerals()
	var dot_order: Array[Spectrum.Hue] = HUES.duplicate()
	var numbers: Array[String] = _arrangements(numerals)
	if fixed_answer.is_empty():
		dot_order.shuffle()
		numbers.shuffle()
	answer = "%d%d%d" % [numerals[0], numerals[1], numerals[2]]
	# The first dot's hue shows the first numeral, and so on along the row.
	var shown: Dictionary[Spectrum.Hue, int] = {}
	for place: int in HUES.size():
		shown[dot_order[place]] = numerals[place]
	scoreboard.digit.digits = shown
	scoreboard.dot_order = dot_order
	for index: int in lockers.size():
		_set_up_locker(lockers[index], numbers[index])


## Returns the three different numerals of the answer, in the order they are read.
func _deal_numerals() -> Array[int]:
	var numerals: Array[int] = []
	if fixed_answer.is_empty():
		var pool: Array[int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
		pool.shuffle()
		numerals.assign(pool.slice(0, HUES.size()))
		return numerals
	for character: String in fixed_answer:
		numerals.append(character.to_int())
	assert(numerals.size() == HUES.size() and numerals[0] != numerals[1] and numerals[0] != numerals[2] and numerals[1] != numerals[2], "Fixed answer must be three different digits.")
	return numerals


## Returns every order of the three [param numerals] as a locker number, six in all.
func _arrangements(numerals: Array[int]) -> Array[String]:
	var numbers: Array[String] = []
	for first: int in numerals.size():
		for second: int in numerals.size():
			if second == first:
				continue
			var third: int = numerals.size() - first - second
			numbers.append("%d%d%d" % [numerals[first], numerals[second], numerals[third]])
	return numbers


## Numbers [param locker], and makes it either the one that holds the crayon or one that rings the alarm.
func _set_up_locker(locker: Locker, number: String) -> void:
	locker.number = number
	locker.is_correct = number == answer
	if locker.is_correct:
		crayon.global_position = locker.contents_spot.global_position
		locker.opened.connect(crayon.appear)
	elif alarm != null:
		locker.rattled.connect(alarm.ring)
