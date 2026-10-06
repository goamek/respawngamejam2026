extends Node
## Tracks the current run of the game: how many lives the player has left.
## Registered as the GameSession autoload, so it survives scene changes.

## Emitted whenever the number of lives changes.
signal lives_changed(lives: int)

## Lives the player starts each run with.
const MAX_LIVES: int = 3

## Lives the player has left in this run.
var lives: int = MAX_LIVES


## Restores every life for a fresh run.
func start_new_game() -> void:
	lives = MAX_LIVES
	lives_changed.emit(lives)


## Takes away one life and returns how many are left.
func lose_life() -> int:
	lives = maxi(lives - 1, 0)
	lives_changed.emit(lives)
	return lives
