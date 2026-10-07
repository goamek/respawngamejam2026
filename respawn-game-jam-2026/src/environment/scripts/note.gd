@tool
class_name Note
extends Node3D
## Sheet of paper with writing on it, read in the world.
## The paper is dim until a light falls on it; the ink never glows, so the writing needs the flashlight.

# The label in the scene is set to cut out, not blend: the crayon screen effect only sees solid surfaces.

## Size the writing is drawn at before scaling; larger is sharper up close.
const FONT_SIZE: int = 64
## Blank border between the edge of the paper and the writing, in meters.
const MARGIN: float = 0.025

## What is written on the paper.
@export_multiline var text: String = "":
	set(value):
		text = value
		_refresh()
## Width and height of the sheet, in meters.
@export var paper_size: Vector2 = Vector2(0.3, 0.4):
	set(value):
		paper_size = value
		_refresh()
## Height of one line of writing, in meters.
@export var text_height: float = 0.03:
	set(value):
		text_height = value
		_refresh()

@onready var _paper: MeshInstance3D = $Paper
@onready var _label: Label3D = $Label


## Shows the starting text.
func _ready() -> void:
	_refresh()


## Sizes the paper and lays the text out to fit inside its margins.
func _refresh() -> void:
	if not is_node_ready():
		return
	# The quad is one meter square and shared by every note, so it is scaled, not resized.
	_paper.scale = Vector3(paper_size.x, paper_size.y, 1.0)
	_label.text = text
	_label.font_size = FONT_SIZE
	_label.pixel_size = text_height / FONT_SIZE
	_label.width = (paper_size.x - MARGIN * 2.0) / _label.pixel_size
