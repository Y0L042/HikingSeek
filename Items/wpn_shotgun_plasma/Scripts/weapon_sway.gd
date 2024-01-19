extends Marker3D

@export var node_root: Node3D
@export var turn_threshold: float = 5
@export var linear_lerp_speed: float = 10
@export var angular_lerp_speed: float = 7
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
	global_position = global_position.lerp(node_root.global_position, linear_lerp_speed * delta)
	global_rotation.x = lerp_angle(global_rotation.x, node_root.global_rotation.x, angular_lerp_speed * delta)
	global_rotation.y = lerp_angle(global_rotation.y, node_root.global_rotation.y, angular_lerp_speed * delta)
	global_rotation.z = lerp_angle(global_rotation.z, node_root.global_rotation.z, angular_lerp_speed * delta)
	if !EDITOR_PREVIEW_ENABLED and Engine.is_editor_hint(): return
	#if !mouse_mov.is_zero_approx():
		#if mouse_mov.x > turn_threshold:
			#rotation = rotation.slerp(sway_left, linear_lerp_speed * delta)
		#elif mouse_mov.x < -turn_threshold:
			#rotation = rotation.slerp(sway_right, linear_lerp_speed * delta)
		#else:
			#rotation = rotation.slerp(sway_normal, linear_lerp_speed * delta)
