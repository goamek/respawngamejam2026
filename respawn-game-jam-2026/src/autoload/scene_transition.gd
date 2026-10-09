extends CanvasLayer
## Changes scene behind a fade to black, loading the next scene in the background so the game never freezes.
## Registered as the SceneTransition autoload, so its black cover stays up while one scene is swapped for the next.

## Time the screen takes to fade to black, in seconds.
@export var fade_out_time: float = 0.4
## Time the next scene takes to fade in out of the black, in seconds.
@export var fade_in_time: float = 1.0
## Time a load may run on under the black before the loading label is shown, in seconds.
@export var label_delay: float = 0.3

## Whether a scene change is under way.
var is_changing: bool = false

@onready var _cover: ColorRect = $Cover
@onready var _label: Label = $Cover/Label


## Starts with the screen clear and the cover letting clicks through.
func _ready() -> void:
	_cover.modulate.a = 0.0
	_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.hide()


## Starts loading the scene at [param scene_path] in the background, so a later change_to() need not wait; does nothing if it is already loading or loaded.
func prepare(scene_path: String) -> void:
	if ResourceLoader.load_threaded_get_status(scene_path) == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		ResourceLoader.load_threaded_request(scene_path)


## Fades to black, switches to the scene at [param scene_path] once it has loaded, and fades back in; does nothing if a change is already under way.
func change_to(scene_path: String) -> void:
	if is_changing:
		return
	is_changing = true
	# The cover swallows clicks from here on, so nothing under it can be pressed while it is fading.
	_cover.mouse_filter = Control.MOUSE_FILTER_STOP
	prepare(scene_path)
	await _fade_to(1.0, fade_out_time)
	var waited: float = 0.0
	while ResourceLoader.load_threaded_get_status(scene_path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
		waited += get_process_delta_time()
		_label.visible = waited >= label_delay
	var scene := ResourceLoader.load_threaded_get(scene_path) as PackedScene
	if scene == null:
		push_error("SceneTransition could not load %s." % scene_path)
	else:
		get_tree().change_scene_to_packed(scene)
		# The first frames of a scene stutter while its materials are made ready; let that happen under the cover.
		await get_tree().process_frame
		await get_tree().process_frame
	_label.hide()
	await _fade_to(0.0, fade_in_time)
	_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_changing = false


## Moves the black cover to [param alpha], from 0 for clear to 1 for black, over [param duration] seconds, and waits until it is there.
func _fade_to(alpha: float, duration: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_cover, "modulate:a", alpha, duration)
	await tween.finished
