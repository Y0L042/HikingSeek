class_name Entity_Player
extends CharacterBody3D

@export_group("Node References")
@export var Body: CharacterBody3D
@export var Spine: Node3D
@export var CrouchHigh: Node3D
@export var CrouchLow: Node3D
@export var BodyShape_Stand: CollisionShape3D
@export var BodyShape_Crouch: CollisionShape3D
@export_subgroup("Raycast Node References")
@export var STEP_UP_RAY_COUNT: float = 8
@export var BaseStepUpSeparationRay: CollisionShape3D

@export_group("Character Settings")
@export_subgroup("Movement")
@export var MOVE_STATS: MovementStatsResource
@export var JUMP_FRAME_GRACE: float = 5
@export var MAX_SLOPE_ANG: float = 60

@onready var _initial_separation_ray_dist: float = abs(BaseStepUpSeparationRay.position.z)
@export_group("WATCH")
var input_flag_is_moving: bool
var input_flag_sprint: bool
var input_flag_jump: bool
@export var input_flag_crouch: bool
var input_value_move_dir: Vector2
@export var body_flag_is_crouching: bool = false
var body_flag_on_ground: bool:
	get:
		return is_on_ground()
var body_value_move_direction: Vector3:
	get:
		return (transform.basis * Vector3(input_value_move_dir.x, 0, input_value_move_dir.y)).normalized()

var _was_on_floor_last_frame: bool = false
var _last_frame_was_on_floor: float = -1 * (JUMP_FRAME_GRACE + 1)
var _snapped_to_stairs_last_frame: bool = false
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var step_vel_threshold: float = 10
var _cur_frame: int
var _last_xz_vel: Vector3
var stepup_ray_list: Array[CollisionShape3D] = []
var velocity_modifiers_array: Array[Callable] = []

@export var _flag_input_crouch_mode_held: bool = false
var _flag_has_stepped: bool

func _ready() -> void:
	_generate_stepup_rays()

func _generate_stepup_rays() -> void:
	stepup_ray_list.append(BaseStepUpSeparationRay)
	for i: int in STEP_UP_RAY_COUNT - 1:
		var new_ray: CollisionShape3D = BaseStepUpSeparationRay.duplicate()
		add_child(new_ray)
		stepup_ray_list.append(new_ray)

func _unhandled_input(event: InputEvent) -> void:
	if _flag_input_crouch_mode_held:
		input_flag_crouch = Input.is_action_pressed("player_crouch")
	else:
		if Input.is_action_just_pressed("player_crouch"):
			input_flag_crouch = !input_flag_crouch
	input_value_move_dir = Input.get_vector("player_left", "player_right", "player_forward", "player_backward")
	input_flag_is_moving = !input_value_move_dir.is_zero_approx()
	input_flag_jump = Input.is_action_just_pressed("player_jump")
	input_flag_sprint = Input.is_action_pressed("player_sprint")

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

func _check_crouch() -> void:
	if input_flag_crouch:
		if !body_flag_is_crouching:
			enter_crouch()
			body_flag_is_crouching = true
		velocity_modifiers_array.append(modify_crouch_speed)
	else:
		if test_exit_crouch():
			exit_crouch()
			body_flag_is_crouching = false

func modify_crouch_speed(i_velocity: Vector3) -> Vector3:
	var xz_vel: Vector3 = i_velocity * Vector3(1, 0 ,1)
	xz_vel = xz_vel.limit_length(MOVE_STATS.ground_walk_speed)
	return Vector3(xz_vel.x, i_velocity.y, xz_vel.z)

func _apply_velocity_modifiers(i_velocity: Vector3) -> Vector3:
	for modifier: Callable in velocity_modifiers_array:
		i_velocity = modifier.call(i_velocity)
	velocity_modifiers_array.clear()
	return i_velocity

func move(delta: float, i_speed: float, i_accel: float) -> void:
	var speed: float = i_speed
	var accel: float = i_accel
	_cur_frame += 1
	if is_on_floor():
		_last_frame_was_on_floor = _cur_frame
	jump()
	_check_crouch()
	velocity.x = lerp(velocity.x, body_value_move_direction.x * speed, delta * accel)
	velocity.z = lerp(velocity.z, body_value_move_direction.z * speed, delta * accel)
	velocity = _apply_velocity_modifiers(velocity)
	_rotate_step_up_separation_ray()
	if _flag_has_stepped and !Input.is_action_pressed("player_jump"): velocity.y = 0
	move_and_slide()
	_snap_down_to_stairs_check()
	_flag_has_stepped = abs(get_real_velocity().y - velocity.y) > step_vel_threshold

func apply_gravity(delta: float) -> void:
	velocity += Vector3.DOWN * MOVE_STATS.gravity_force * delta

func jump() -> void:
	if Input.is_action_just_pressed("player_jump") and (is_on_floor() or _cur_frame - _last_frame_was_on_floor <= JUMP_FRAME_GRACE):
		velocity.y = MOVE_STATS.ground_jump_force

func is_on_ground() -> bool:
	#return (is_on_floor() or _cur_frame - _last_frame_was_on_floor <= JUMP_FRAME_GRACE)
	return (is_on_floor() or _was_on_floor_last_frame)

func enter_crouch() -> void:
	var enter_time: float = 0.125
	BodyShape_Stand.disabled = true
	BodyShape_Crouch.disabled = false
	var tween: Tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(Spine, "position", CrouchLow.position, enter_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)

func test_exit_crouch() -> bool:
	var uncrouch_ray: RayCast3D = BodyShape_Crouch.get_child(0) as RayCast3D
	uncrouch_ray.force_raycast_update()
	if uncrouch_ray.is_colliding():
		return false
	return true

func exit_crouch() -> void:
	var exit_time: float = 0.15
	BodyShape_Stand.disabled = false
	BodyShape_Crouch.disabled = true
	var tween: Tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(Spine, "position", CrouchHigh.position, exit_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
