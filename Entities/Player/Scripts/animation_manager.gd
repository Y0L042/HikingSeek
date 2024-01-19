class_name PlayerAnimationManager
extends Node3D

@export_group("Node References")
@export var node_root: Node3D
@export_subgroup("Character Rig")
@export var LeftIK: SkeletonIK3D
@export var RightIK: SkeletonIK3D
@export var LeftIK_Target: Node3D
@export var RightIK_Target: Node3D

var ENABLE_IK: bool:
	get:
		return ENABLE_IK
	set(value):
		ENABLE_IK = value
		if value:
			LeftIK.start()
			RightIK.start()
		else:
			LeftIK.stop()
			RightIK.stop()

func _ready() -> void:
	LeftIK.start()
	RightIK.start()

func _physics_process(delta: float) -> void:
	return
	var xform: Transform3D = Transform3D.IDENTITY
	xform.origin = global_position + global_transform.basis.z * -3
	set_hand_ik_target(xform)

func set_hand_ik_target(i_target_xform: Transform3D) -> void:
	ENABLE_IK = true
	i_target_xform.basis.z = i_target_xform.basis.z.rotated(Vector3.RIGHT, deg_to_rad(90))
	LeftIK.target = i_target_xform
	RightIK.target = i_target_xform

func reset_hand_ik_target() -> void:
	ENABLE_IK = false

func start_ik() -> void:
	pass
