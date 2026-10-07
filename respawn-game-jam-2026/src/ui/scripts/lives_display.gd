class_name LivesDisplay
extends Control
## Row of hearts showing the player's lives: filled for each life left, empty for each one lost.
## Hearts empty from left to right, and are drawn in code, so no image is needed.

## Number of points used to trace each heart's outline.
const HEART_POINTS: int = 48

## Fill color of a heart for a life the player still has.
@export var full_color: Color = Color(0.85, 0.08, 0.12)
## Color of every heart's outline, full or empty.
@export var outline_color: Color = Color(0.0, 0.0, 0.0)
## Width and height of each heart, in pixels.
@export var heart_size: float = 40.0
## Gap between hearts, in pixels.
@export var spacing: float = 10.0
## Thickness of the outline, in pixels.
@export var outline_width: float = 3.0

var _heart_shape: PackedVector2Array


## Builds the heart shape, sizes the row, and redraws whenever the lives change.
func _ready() -> void:
	_heart_shape = _build_heart_shape()
	var hearts: int = GameSession.MAX_LIVES
	custom_minimum_size = Vector2(hearts * heart_size + (hearts - 1) * spacing, heart_size)
	GameSession.lives_changed.connect(_on_game_session_lives_changed)
	queue_redraw()


## Draws one outlined heart per starting life; the rightmost hearts are filled, one for each life left.
func _draw() -> void:
	var lost: int = GameSession.MAX_LIVES - GameSession.lives
	for index: int in GameSession.MAX_LIVES:
		var center := Vector2(heart_size * 0.5 + index * (heart_size + spacing), heart_size * 0.5)
		var outline: PackedVector2Array = _heart_at(center)
		if index >= lost:
			draw_colored_polygon(outline, full_color)
		var closed: PackedVector2Array = outline.duplicate()
		closed.append(outline[0])
		draw_polyline(closed, outline_color, outline_width, true)


## Redraws the hearts for the new number of lives.
func _on_game_session_lives_changed(_lives: int) -> void:
	queue_redraw()


## Returns the heart shape moved to [param center] and scaled to the heart size.
func _heart_at(center: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	for point: Vector2 in _heart_shape:
		points.append(center + point * heart_size)
	return points


## Returns a heart outline centered on the origin, fitted inside a 1 by 1 square.
func _build_heart_shape() -> PackedVector2Array:
	# The classic heart curve: x = 16 sin^3 t, y = 13 cos t - 5 cos 2t - 2 cos 3t - cos 4t.
	var raw := PackedVector2Array()
	for step: int in HEART_POINTS:
		var t: float = TAU * step / HEART_POINTS
		var x: float = 16.0 * pow(sin(t), 3.0)
		var y: float = 13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t)
		raw.append(Vector2(x, -y))
	var low := Vector2(INF, INF)
	var high := Vector2(-INF, -INF)
	for point: Vector2 in raw:
		low = low.min(point)
		high = high.max(point)
	var middle: Vector2 = (low + high) * 0.5
	var scale_factor: float = 1.0 / maxf(high.x - low.x, high.y - low.y)
	var shape := PackedVector2Array()
	for point: Vector2 in raw:
		shape.append((point - middle) * scale_factor)
	return shape
