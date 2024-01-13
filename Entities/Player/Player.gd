extends CharacterBody3D

@export_group("Node References")
@export var Body: CharacterBody3D
@export var Head: Node3D
@export var HeadTarget: Node3D
@export_subgroup("Raycast Node References")
@export var STEP_UP_RAY_COUNT: float = 8
@export var BaseStepUpSeparationRay: CollisionShape3D

@export_group("Character Settings")
@export_subgroup("Movement")
@export var WALK_SPEED: float = 5.0
@export var SPRINT_SPEED: float = 8.0
@export var JUMP_VELOCITY: float = 4.8
@export var SENSITIVITY: float = 0.004
@export var JUMP_FRAME_GRACE: float = 5
@export var MAX_SLOPE_ANG: float = 60
# bob variables
@export_subgroup("HeadBob")
@export var BOB_EFFECTS_ENABLED: bool = false
@export var BOB_FREQ: float = 2.4
@export var BOB_AMP: float = 0.08
@export var HEADSPRING: float = 1
# fov variables
@export var FOV_EFFECTS_ENABLED: bool = false
@export var BASE_FOV: float = 100.0
@export var FOV_CHANGE: float = 1.5

@onready var _initial_separation_ray_dist: float = abs(BaseStepUpSeparationRay.position.z)

var input_flag_is_moving: bool
var input_flag_sprint: bool
var input_flag_jump: bool
var input_value_move_dir: Vector2
var body_flag_on_ground: bool:
	get:
		return is_on_floor()
var body_value_on_ground_point: Vector3
var body_value_move_direction: Vector3:
	get:
		return (transform.basis * Vector3(input_value_move_dir.x, 0, input_value_move_dir.y)).normalized()

var stepup_ray_list: Array[CollisionShape3D] = []
var speed: float
var camera_offset: Vector3
var t_bob: float
var _cur_frame: int
var _last_xz_vel: Vector3
var _last_frame_was_on_floor: float = -JUMP_FRAME_GRACE - 1
var _was_on_floor_last_frame: bool = false
var _snapped_to_stairs_last_frame: bool = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var step_vel_threshold: float = 10
var _flag_has_stepped: bool
var _input_crouch_mode_held: bool
var _flag_input_crouch: bool


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_generate_stepup_rays()



func _generate_stepup_rays() -> void:
	stepup_ray_list.append(BaseStepUpSeparationRay)
	for i: int in STEP_UP_RAY_COUNT - 1:
		var new_ray: CollisionShape3D = BaseStepUpSeparationRay.duplicate()
		add_child(new_ray)
		stepup_ray_list.append(new_ray)



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		Body.global_rotate(Vector3.UP, -event.relative.x * SENSITIVITY)
		Head.rotate_x(-event.relative.y * SENSITIVITY)
		Head.rotation.x = clamp(Head.rotation.x, deg_to_rad(-88), deg_to_rad(88))
	if _input_crouch_mode_held:
		_flag_input_crouch = Input.is_action_pressed("player_crouch")
	else:
		if Input.is_action_just_pressed("player_crouch"):
			_flag_input_crouch = !_flag_input_crouch
	input_value_move_dir = Input.get_vector("player_left", "player_right", "player_forward", "player_backward")
	input_flag_is_moving = !input_value_move_dir.is_zero_approx()
	input_flag_jump = Input.is_action_just_pressed("player_jump")
	input_flag_sprint = Input.is_action_pressed("player_sprint")


func _physics_process(delta: float) -> void:
	# Add gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	_cur_frame += 1
	if is_on_floor():
		_last_frame_was_on_floor = _cur_frame
	if Input.is_action_just_pressed("player_jump") and (is_on_floor() or _cur_frame - _last_frame_was_on_floor <= JUMP_FRAME_GRACE):
		velocity.y = JUMP_VELOCITY

	# Handle Sprint.
	if Input.is_action_pressed("player_sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir: Vector2 = Input.get_vector("player_left", "player_right", "player_forward", "player_backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

	_rotate_step_up_separation_ray()
	if _flag_has_stepped and !Input.is_action_pressed("player_jump"): velocity.y = 0
	move_and_slide()
	_snap_down_to_stairs_check()

	_flag_has_stepped = abs(get_real_velocity().y - velocity.y) > step_vel_threshold

	if BOB_EFFECTS_ENABLED:
		_juice_camera(delta)



func _snap_down_to_stairs_check() -> void:
	var did_snap: bool = false
	if not is_on_floor() and velocity.y <= 0 and (_was_on_floor_last_frame or _snapped_to_stairs_last_frame) and $StairsBelowRayCast3D.is_colliding():
		var body_test_result: PhysicsTestMotionResult3D = PhysicsTestMotionResult3D.new()
		var params: PhysicsTestMotionParameters3D = PhysicsTestMotionParameters3D.new()
		var max_step_down: float = -0.5
		params.from = self.global_transform
		params.motion = Vector3(0,max_step_down,0)
		if PhysicsServer3D.body_test_motion(self.get_rid(), params, body_test_result):
			var translate_y: float = body_test_result.get_travel().y
			self.position.y += translate_y
			apply_floor_snap()
			did_snap = true

	_was_on_floor_last_frame = is_on_floor()
	_snapped_to_stairs_last_frame = did_snap



func _rotate_step_up_separation_ray() -> void:
	var character: CharacterBody3D = self
	var angle_step: float = 360.0 / STEP_UP_RAY_COUNT
	var xz_vel: Vector3 = character.velocity * Vector3(1, 0, 1)
	if xz_vel.length() < 0.1:
		xz_vel = _last_xz_vel
	else:
		_last_xz_vel = xz_vel

	for ray_idx: int in range(STEP_UP_RAY_COUNT):
		var ray_angle: float = deg_to_rad(angle_step * ray_idx)
		var xz_ray_pos: Vector3 = xz_vel.normalized() * _initial_separation_ray_dist
		xz_ray_pos = xz_ray_pos.rotated(Vector3(0, 1.0, 0), ray_angle)

		var ray: CollisionShape3D = stepup_ray_list[ray_idx]
		ray.global_position.x = character.global_position.x + xz_ray_pos.x
		ray.global_position.z = character.global_position.z + xz_ray_pos.z

	# Checking steepness for each ray
	var any_too_steep: bool = false
	for ray: CollisionShape3D in stepup_ray_list:
		var raycast: RayCast3D = ray.get_child(0)
		raycast.force_raycast_update()  # Update the raycast
		if raycast.is_colliding():
			var ray_normal: Vector3 = raycast.get_collision_normal()
			if ray_normal.dot(Vector3(0, 1, 0)) < sin(deg_to_rad(MAX_SLOPE_ANG)):
				any_too_steep = true
				break  # Exit loop if any ray hits a steep slope

	# Take action based on the steepness check
	for ray: CollisionShape3D in stepup_ray_list:
		ray.disabled = any_too_steep



func _juice_camera(delta: float) -> void:
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	%Camera3D.transform.origin = _headbob(t_bob)

	# FOV
	if !FOV_EFFECTS_ENABLED: return
	var velocity_clamped: float = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov: float = BASE_FOV + FOV_CHANGE * velocity_clamped
	%Camera3D.fov = lerp(%Camera3D.fov, target_fov, delta * 8.0)



func _headbob(time: float) -> Vector3:
	var pos: Vector3 = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	#to fix this need to teleport with camera child in portal for CharacterBody3D
	return pos
