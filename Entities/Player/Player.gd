class_name Entity_Player
extends EntityBaseClass

#region Export Variables
@export_group("Node References")
@export_subgroup("Character Body")
@export var Body: CharacterBody3D
@export var Spine: Node3D
@export var Head: Node3D
@export var CrouchHigh: Node3D
@export var CrouchLow: Node3D
@export var BodyShape_Stand: CollisionShape3D
@export var BodyShape_Crouch: CollisionShape3D
@export var Interact_Raycast: RayCast3D
@export var Pickup_Container: Marker3D
@export var player_animation_manager: PlayerAnimationManager
@export_subgroup("StairStep and Vault Raycast Node References")
@export var STEP_UP_RAY_COUNT: float = 8
@export var BaseStepUpSeparationRay: CollisionShape3D
@export var StairBelowRay: RayCast3D
@export var VaultRay: RayCast3D
@export var VaultShapeCast: ShapeCast3D
@export_group("Character Settings")
@export_subgroup("Movement")
@export var MOVE_STATS: MovementStatsResource
@export var JUMP_FRAME_GRACE: float = 5
@export var MAX_SLOPE_ANG: float = 60
#endregion Export Variables

#region Input and Body Flags
@onready var _initial_separation_ray_dist: float = abs(BaseStepUpSeparationRay.position.z)
var input_flag_is_moving: bool
var input_flag_sprint: bool
var input_flag_jump: bool
var input_flag_crouch: bool
var input_flag_pickup: bool
var input_flag_interact: bool
var input_value_move_dir: Vector2
var body_flag_is_crouching: bool = false
var body_flag_is_vaulting: bool = false
var body_flag_on_ground: bool:
	get:
		return is_on_ground()
var body_value_move_direction: Vector3:
	get:
		return (transform.basis * Vector3(input_value_move_dir.x, 0, input_value_move_dir.y)).normalized()
var body_flag_on_climbable: bool = false

var _flag_input_crouch_mode_held: bool = false
var _flag_has_stepped: bool
#endregion Input and Body Flags

var _was_on_floor_last_frame: bool = false
var _last_frame_was_on_floor: float = -1 * (JUMP_FRAME_GRACE + 1)
var _snapped_to_stairs_last_frame: bool = false
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var step_vel_threshold: float = 10
var _cur_frame: int
var _last_xz_vel: Vector3
var stepup_ray_list: Array[CollisionShape3D] = []
var velocity_modifiers_array: Array[Callable] = []

var _in_climbable_range: bool = false
var in_climbable_range: bool:
	get:
		return _in_climbable_range
	set(value):
		_in_climbable_range = value
		on_climbable = value
var on_climbable: bool = false

var pickedup_object: Node3D


func _ready() -> void:
	add_to_group("Entity_Player")
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
	input_flag_interact = Input.is_action_just_pressed("player_interact")
	input_flag_pickup = Input.is_action_just_pressed("player_pickup")
	execute_actions()

func _snap_down_to_stairs_check() -> void:
	var did_snap: bool = false
	if  !is_on_floor() and velocity.y <= 0 and (_was_on_floor_last_frame or _snapped_to_stairs_last_frame) and StairBelowRay.is_colliding():
		var body_test_result: PhysicsTestMotionResult3D = PhysicsTestMotionResult3D.new()
		var params: PhysicsTestMotionParameters3D = PhysicsTestMotionParameters3D.new()
		#var max_step_down: float = -0.5
		var max_step_down: float = StairBelowRay.target_position.y
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

func _push_rigidbodies() -> void:
	var push_force: float = 0.1
	push_force = push_force * velocity.length()
	push_force = clampf(push_force, 1, INF)
	for i: int in get_slide_collision_count():
		var col: KinematicCollision3D = get_slide_collision(i)
		if col.get_collider() is RigidBody3D:
			if col.get_normal().dot(Vector3.UP) > 0.707: return
			var collider: RigidBody3D = col.get_collider()
			#col.get_collider().apply_central_force(-col.get_normal() * push_force)
			col.get_collider().apply_central_impulse(-col.get_normal() * push_force)
			pass

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
	test_for_climbable()
	velocity.x = lerp(velocity.x, body_value_move_direction.x * speed, delta * accel)
	velocity.z = lerp(velocity.z, body_value_move_direction.z * speed, delta * accel)
	if body_flag_is_crouching and is_on_ground(): velocity_modifiers_array.append(modify_crouch_speed)
	velocity = _apply_velocity_modifiers(velocity)
	_rotate_step_up_separation_ray()
	if _flag_has_stepped and !Input.is_action_pressed("player_jump"): velocity.y = 0 #Neutralize Y Vel if player just want to get over edge of object
	move_and_slide()
	_push_rigidbodies()
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

func execute_actions() -> void:
	if Input.is_action_pressed("player_crouch"): crouch()
	var has_vaulted: bool
	# If player is holding jump and moving forward, vault. If they vaulted, don't jump.
	# If the player just tapped jump, or is not moving forward, don't vault, jump.
	if Input.is_action_pressed('player_jump'):
		if !body_flag_is_crouching and !body_flag_is_vaulting:
			if input_value_move_dir.y < 0:
				has_vaulted = vault()
	if Input.is_action_just_pressed("player_jump"):
		if !has_vaulted:
			jump()

func crouch() -> void:
	if input_flag_crouch:
		if !body_flag_is_crouching:
			enter_crouch()
			body_flag_is_crouching = true
		#velocity_modifiers_array.append(modify_crouch_speed)
	else:
		if body_flag_is_crouching and test_exit_crouch():
			exit_crouch()
			body_flag_is_crouching = false

func modify_crouch_speed(i_velocity: Vector3) -> Vector3:
	var xz_vel: Vector3 = i_velocity * Vector3(1, 0 ,1)
	xz_vel = xz_vel.limit_length(MOVE_STATS.ground_walk_speed)
	return Vector3(xz_vel.x, i_velocity.y, xz_vel.z)

func enter_crouch() -> void:
	var enter_time: float = 0.125
	BodyShape_Stand.disabled = true
	BodyShape_Crouch.disabled = false
	if !is_on_ground():
		global_position.y += CrouchHigh.position.y - CrouchLow.position.y
		Spine.position = CrouchLow.position
		return
	var tween: Tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(Spine, "position", CrouchLow.position, enter_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)

func test_exit_crouch() -> bool:
	var uncrouch_shape: ShapeCast3D = BodyShape_Crouch.get_child(0) as ShapeCast3D
	uncrouch_shape.force_shapecast_update()
	print("Can uncrouch? : ", !uncrouch_shape.is_colliding())
	if uncrouch_shape.is_colliding():
		return false
	return true

func exit_crouch() -> void:
	var exit_time: float = 0.15
	BodyShape_Stand.disabled = false
	BodyShape_Crouch.disabled = true
	if !is_on_ground():
		global_position.y -= CrouchHigh.position.y - CrouchLow.position.y
		Spine.position = CrouchHigh.position
		return
	var tween: Tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(Spine, "position", CrouchHigh.position, exit_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)

func vault() -> bool:
	if !is_on_ground():
		VaultRay.target_position.y = -1.75
	else:
		VaultRay.target_position.y = -0.75
	VaultRay.force_raycast_update()
	if VaultRay.is_colliding():
		var ray_normal: Vector3 = VaultRay.get_collision_normal()
		if ray_normal.dot(Vector3(0, 1, 0)) < sin(deg_to_rad(MAX_SLOPE_ANG)):
			#DebugDraw3D.draw_sphere(VaultRay.get_collision_point() + Vector3.UP * 0.25, 0.25, Color.FIREBRICK, 30) # HACK
			return false
		VaultShapeCast.global_position = VaultRay.get_collision_point() + Vector3.UP * VaultShapeCast.shape.height/2 + Vector3(0, 0.01, 0)
		VaultShapeCast.force_shapecast_update()
		if VaultShapeCast.is_colliding():
			#DebugDraw3D.draw_sphere(VaultRay.get_collision_point() + Vector3.UP * 0.25, 0.25, Color.WEB_MAROON, 30) # HACK
			return false
		#DebugDraw3D.draw_sphere(VaultRay.get_collision_point() + Vector3.UP * 0.25, 0.25, Color.CHARTREUSE, 30) # HACK
		body_flag_is_vaulting = true
		var y_time: float = 0.85
		var xz_time: float = 0.75
		var tween_y: Tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tween_y.tween_property(self, "global_position:y", VaultRay.get_collision_point().y, y_time).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
		tween_y.tween_callback((func() -> void: body_flag_is_vaulting = false))
		var tween_x: Tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tween_x.tween_property(self, "global_position:x", VaultRay.get_collision_point().x, xz_time).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
		var tween_z: Tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tween_z.tween_property(self, "global_position:z", VaultRay.get_collision_point().z, xz_time).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
		return true
	return false

func test_for_climbable() -> void:
	if in_climbable_range and !is_on_floor():
		if on_climbable:
			if Input.is_action_just_pressed('player_jump'):
				GDebug.print(self, ["Jump OFF climbable"], 'blue')
				jump_off_climbable()
				var tween: Tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
				tween.tween_property(self, "on_climbable", false, 0.5)
		elif !on_climbable:
			on_climbable = true
			GDebug.print(self, ["Climb ON climbable"], 'green')
	else:
		on_climbable = false

func process_on_climbable(delta: float) -> void:
	test_for_climbable()
	var CLIMBABLE_SPEED: float = 2
	var input_dir: Vector2 = input_value_move_dir
	# Applying ladder input_dir to direction
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x,input_dir.y * -1,0)).normalized()
	velocity = direction * CLIMBABLE_SPEED
	move_and_slide()

func jump_off_climbable() -> void:
	on_climbable = false
	var look_vector: Vector3 = -Head.global_transform.basis.z
	var jump_vel: Vector3 = velocity + (look_vector + Vector3.UP) * Vector3.ONE * MOVE_STATS.ground_jump_force
	velocity_modifiers_array.append(func(i_vel) -> Vector3: return jump_vel)

