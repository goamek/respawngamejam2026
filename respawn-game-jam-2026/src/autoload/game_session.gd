extends Node
## Tracks the current run of the game: how many lives the player has left, and how the run ended. Also holds the brightness setting and which endings have been found.
## Registered as the GameSession autoload, so it survives scene changes.

## Emitted whenever the number of lives changes.
signal lives_changed(lives: int)

## Ways a run can end.
enum Ending { ESCAPE, UNCOVERED, CAUGHT }

## Lives the player starts each run with.
const MAX_LIVES: int = 3
## How many different endings count as winning.
const WINNING_ENDING_COUNT: int = 2

## Lives the player has left in this run.
var lives: int = MAX_LIVES
## How the last run ended; set as a level is left, and read by the ending screen.
var ending: Ending = Ending.CAUGHT
## How bright the 3D picture is drawn, as a multiple of how the level is lit; starts a little dark, is chosen in the pause menu, and is kept from run to run.
var brightness: float = 0.5

## Winning endings reached since the game was opened; kept from run to run, and not saved to disk.
var _endings_found: Array[Ending] = []


## Restores every life for a fresh run.
func start_new_game() -> void:
	lives = MAX_LIVES
	lives_changed.emit(lives)


## Notes [param reached] as found if it is a winning ending not reached before; being caught does not count.
func record_ending(reached: Ending) -> void:
	if reached != Ending.CAUGHT and not _endings_found.has(reached):
		_endings_found.append(reached)


## Returns how many different winning endings have been found since the game was opened.
func endings_found() -> int:
	return _endings_found.size()


## Takes away one life and returns how many are left.
func lose_life() -> int:
	lives = maxi(lives - 1, 0)
	lives_changed.emit(lives)
	return lives
