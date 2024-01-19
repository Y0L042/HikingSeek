extends Marker3D

@export var sway_threshold: float = 5
@export var sway_lerp: float = 5
@export var sway_left: Vector3
@export var sway_right: Vector3
@export var sway_normal: Vector3

@export var EDITOR_PREVIEW_ENABLED: bool = false:
	get:
		return EDITOR_PREVIEW_ENABLED
	set(value):
		EDITOR_PREVIEW_ENABLED = value
		if value:
			_base_xform = transform
		else:
			transform = _base_xform

var mouse_mov: Vector2
var _base_xform: Transform3D = Transform3D.IDENTITY

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_mov = -event.relative

func _physics_process(delta: float) -> void:
	if !EDITOR_PREVIEW_ENABLED and Engine.is_editor_hint(): return
	if !mouse_mov.is_zero_approx():
		if mouse_mov.x > sway_threshold:
			rotation = rotation.slerp(sway_left, sway_lerp * delta)
		elif mouse_mov.x < -sway_threshold:
			rotation = rotation.slerp(sway_right, sway_lerp * delta)
		else:
			rotation = rotation.slerp(sway_normal, sway_lerp * delta)
