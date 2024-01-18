class_name PickUpAble
extends Node3D

@export_group("Carriable Settings")
@export var node_root: RigidBody3D
@export var collision_shape: CollisionShape3D
@export var move_to_target_speed: float = 25
@export var max_distance: float = INF

var is_being_carried: bool
var holder: Variant
var target_container: Node3D
var force_holder_to_drop: Callable
var original_col_mask: int
var original_col_layer: int

signal pickedup
signal dropped
signal thrown
signal beingcarried

func _ready() -> void:
	node_root.add_to_group(GRef.GROUP_INTERACTIBLE_PICKUPABLE)
	original_col_mask = node_root.collision_mask
	original_col_layer = node_root.collision_layer

func _physics_process(delta: float) -> void:
	if is_being_carried:
		var dist_exceeded: bool = be_carried(delta)
		if dist_exceeded:
			force_holder_to_drop.call()

func be_carried(delta: float) -> bool:
	beingcarried.emit(holder)
	var dist_exceeded: bool = false
	#node_root.global_position = target_container.global_position
	var target_dist_sqrd: float = move_towards_target(target_container.global_position)
	node_root.global_rotation = Vector3.ZERO
	node_root.global_rotation.y = target_container.global_rotation.y
	#node_root.linear_velocity = Vector3.ZERO
	node_root.angular_velocity = Vector3.ZERO
	if target_dist_sqrd > max_distance * max_distance:
		dist_exceeded = true
	return dist_exceeded

func hold(i_holder: Node3D, i_force_holder_to_drop: Callable, i_target_container: Node3D) -> void:
	pickedup.emit(holder)
	holder = i_holder
	target_container = i_target_container
	force_holder_to_drop = i_force_holder_to_drop
	#node_root.collision_mask = original_col_mask - holder.collision_layer
	#holder.collision_mask -= node_root.collision_layer
	#collision_shape.disabled = true
	is_being_carried = true

func drop() -> void:
	dropped.emit(holder)
	#node_root.collision_mask = original_col_mask
	#holder.collision_mask += node_root.collision_layer
	holder = null
	target_container = null
	collision_shape.disabled = false
	is_being_carried = false

func throw(direction: Vector3, power: float) -> void:
	thrown.emit(holder)
	holder = null
	target_container = null
	collision_shape.disabled = false
	is_being_carried = false
	direction = direction.normalized()
	power = clampf(power/node_root.mass, power/10, power)
	node_root.apply_central_impulse(direction * Vector3.ONE * power)


func move_towards_target(i_target: Vector3) -> float:
	var current_pos: Vector3 = node_root.global_position
	var path: Vector3 = i_target - current_pos
	var path_length_sqrd: float = path.length_squared()
	var dir: Vector3 = path.normalized()
	node_root.linear_velocity = dir * move_to_target_speed * clampf(path_length_sqrd, 0, 1.1)
	return path_length_sqrd
