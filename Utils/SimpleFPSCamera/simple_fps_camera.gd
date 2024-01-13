@icon("./icons/icons8-gopro-100.png")
class_name SimpleFPSCamera
extends Camera3D

@export_group("Node References")
@export var character: CharacterBody3D
@export var rot_target_y: Node3D
@export var rot_target_x: Node3D

@export_group("Settings")
@export var enable_fps_camera: bool = true

@export_group("Config Settings TODO")
@export_range(1, 100, 5) var MOUSE_SENSITIVITY: float = 50
@export var LOOK_DOWN_CLAMP_DEG: float = 89
@export var LOOK_UP_CLAMP_DEG: float = 89

@export_group("Head Bob")
# bob variables
@export var BOB_EFFECTS_ENABLED: bool = false
@export var BOB_FREQ: float = 2.4
@export var BOB_AMP: float = 0.08
@export var HEADSPRING: float = 1
# fov variables
@export var FOV_EFFECTS_ENABLED: bool = false
@export var BASE_FOV: float = 100.0
@export var FOV_CHANGE: float = 1.5
@export var MAX_FOV_SPEED: float = 10

var t_bob: float

func _unhandled_input(event: InputEvent) -> void:
	if enable_fps_camera: handle_mouse_look(event)

func handle_mouse_look(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var sensitivity: float = MOUSE_SENSITIVITY / 500
		# 1. First rotate Y
		rot_target_y.rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		# 2. Second rotate X
		rot_target_x.rotate_x(deg_to_rad(-event.relative.y * sensitivity)) # we only tilt the camera up and down
		rot_target_x.rotation.x = clamp(rot_target_x.rotation.x, deg_to_rad(-LOOK_DOWN_CLAMP_DEG), deg_to_rad(LOOK_UP_CLAMP_DEG))

func _physics_process(delta: float) -> void:
	if BOB_EFFECTS_ENABLED: _juice_camera(delta)

func _juice_camera(delta: float) -> void:
	# Head bob
	t_bob += delta * character.velocity.length() * float(character.is_on_floor())
	transform.origin = _headbob(t_bob)

	# FOV
	if !FOV_EFFECTS_ENABLED: return
	var velocity_clamped: float = clamp(character.velocity.length(), 0.5, MAX_FOV_SPEED * 2)
	var target_fov: float = BASE_FOV + FOV_CHANGE * velocity_clamped
	fov = lerp(fov, target_fov, delta * 8.0)

func _headbob(time: float) -> Vector3:
	var pos: Vector3 = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	#to fix this need to teleport with camera child in portal for CharacterBody3D
	return pos
