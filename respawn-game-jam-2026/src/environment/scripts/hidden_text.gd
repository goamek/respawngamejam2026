class_name HiddenText
extends Node3D
## Writing on a dark tag that only shows under a beam of its hue, or a white beam.
## The tag is as dark as the hidden writing, so in any other light the writing cannot be made out.

## Size the writing is drawn at before scaling; larger is sharper up close.
const FONT_SIZE: int = 64

## What is written on the tag.
@export var text: String = ""
## Hue the flashlight must shine for the writing to show.
@export var hue: Spectrum.Hue = Spectrum.Hue.YELLOW
## Height of the letters, in meters.
@export var text_height: float = 0.05
## Width and height of the dark tag behind the writing, in meters.
@export var tag_size: Vector2 = Vector2(0.3, 0.1)

@onready var _tag: MeshInstance3D = $Tag
@onready var _writing: MeshInstance3D = $Writing
@onready var _revealable: Revealable = $Writing/Revealable


## Sizes the tag and writes the text in its hue.
func _ready() -> void:
	# The quad is one meter square and shared by every tag, so it is scaled, not resized.
	_tag.scale = Vector3(tag_size.x, tag_size.y, 1.0)
	var letters: TextMesh = _writing.mesh
	letters.text = text
	letters.font_size = FONT_SIZE
	letters.pixel_size = text_height / FONT_SIZE
	_revealable.hue = hue
