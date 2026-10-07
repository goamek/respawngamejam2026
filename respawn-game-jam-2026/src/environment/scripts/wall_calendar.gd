@tool
class_name WallCalendar
extends Node3D
## Wall calendar showing one month, with one day circled and a short note written under it.
## Like a note, its paper is dim until a light falls on it.

## Size the writing is drawn at before scaling; larger is sharper up close.
const FONT_SIZE: int = 64
## Columns in the grid, one per day of the week.
const WEEK_LENGTH: int = 7
## Rows the sheet is divided into: the month, the weekday letters, and up to six weeks.
const ROW_COUNT: int = 9
## Letters heading the columns, starting on Sunday.
const WEEKDAY_LETTERS: PackedStringArray = ["S", "M", "T", "W", "T", "F", "S"]
## Color of the day numbers.
const INK_COLOR: Color = Color(0.05, 0.04, 0.04)
## Color of the circle and the note, as if added by hand in red pen.
const PEN_COLOR: Color = Color(0.55, 0.05, 0.05)

## Name printed across the top.
@export var month_name: String = "OCTOBER":
	set(value):
		month_name = value
		_rebuild()
## Number of days in the month.
@export_range(28, 31) var day_count: int = 31:
	set(value):
		day_count = value
		_rebuild()
## Column the first day falls in: 0 is Sunday, 6 is Saturday.
@export_range(0, 6) var first_weekday: int = 4:
	set(value):
		first_weekday = value
		_rebuild()
## Day with a circle drawn round it; 0 circles nothing.
@export_range(0, 31) var circled_day: int = 21:
	set(value):
		circled_day = value
		_rebuild()
## Words written along the bottom in the same pen as the circle.
@export var circle_note: String = "book due!":
	set(value):
		circle_note = value
		_rebuild()
## Width and height of the sheet, in meters.
@export var paper_size: Vector2 = Vector2(0.8, 0.8):
	set(value):
		paper_size = value
		_rebuild()

@onready var _paper: MeshInstance3D = $Paper
@onready var _marks: Node3D = $Marks


## Draws the starting month.
func _ready() -> void:
	_rebuild()


## Clears the sheet and writes the month, the weekday letters, every day, the circle, and the note.
func _rebuild() -> void:
	if not is_node_ready():
		return
	for mark: Node in _marks.get_children():
		_marks.remove_child(mark)
		mark.queue_free()
	_paper.scale = Vector3(paper_size.x, paper_size.y, 1.0)
	var cell := Vector2(paper_size.x / (WEEK_LENGTH + 1), paper_size.y / (ROW_COUNT + 1))
	_write(month_name, Vector2(0.0, _row_height(0, cell)), cell.y * 0.8, INK_COLOR)
	for column: int in WEEK_LENGTH:
		_write(WEEKDAY_LETTERS[column], Vector2(_column_offset(column, cell), _row_height(1, cell)), cell.y * 0.5, INK_COLOR)
	for day: int in range(1, day_count + 1):
		var slot: int = first_weekday + day - 1
		# Whole weeks only: the days left over pick the column, so dropping the remainder is intended.
		@warning_ignore("integer_division")
		var week: int = slot / WEEK_LENGTH
		var spot := Vector2(_column_offset(slot % WEEK_LENGTH, cell), _row_height(2 + week, cell))
		_write(str(day), spot, cell.y * 0.55, INK_COLOR)
		if day == circled_day:
			_circle(spot, minf(cell.x, cell.y) * 0.5)
	_write(circle_note, Vector2(0.0, _row_height(ROW_COUNT - 1, cell)), cell.y * 0.6, PEN_COLOR)


## Returns how far left or right of the middle [param column] sits, in meters.
func _column_offset(column: int, cell: Vector2) -> float:
	return (column - (WEEK_LENGTH - 1) / 2.0) * cell.x


## Returns how far above or below the middle [param row] sits, in meters; row 0 is the top.
func _row_height(row: int, cell: Vector2) -> float:
	return ((ROW_COUNT - 1) / 2.0 - row) * cell.y


## Adds [param words] to the sheet at [param spot], with letters [param height] meters tall.
func _write(words: String, spot: Vector2, height: float, color: Color) -> void:
	var label := Label3D.new()
	label.text = words
	label.font_size = FONT_SIZE
	label.pixel_size = height / FONT_SIZE
	label.modulate = color
	label.outline_size = 0
	label.double_sided = false
	# Cut out, not blended: the crayon screen effect only sees solid surfaces, so see-through text vanishes.
	label.alpha_cut = Label3D.ALPHA_CUT_DISCARD
	label.position = Vector3(spot.x, spot.y, 0.003)
	_marks.add_child(label)


## Draws a ring of [param radius] meters round [param spot].
func _circle(spot: Vector2, radius: float) -> void:
	var ring := TorusMesh.new()
	ring.outer_radius = radius
	ring.inner_radius = radius * 0.86
	var pen := StandardMaterial3D.new()
	pen.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pen.albedo_color = PEN_COLOR
	ring.material = pen
	var mesh := MeshInstance3D.new()
	mesh.mesh = ring
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# A torus lies flat by default; stood up and squashed, it becomes a ring drawn on the paper.
	mesh.transform = Transform3D(Basis(Vector3.RIGHT, PI / 2.0).scaled(Vector3(1.0, 1.0, 0.05)), Vector3(spot.x, spot.y, 0.004))
	_marks.add_child(mesh)
