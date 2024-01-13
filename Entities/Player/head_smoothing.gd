extends Node3D

@export_group("Node References")
@export var HeadRoot: Node3D
@export_group("Smoothing Settings")
@export var SMOOTHING_ENABLED: bool = false

func _physics_process(delta: float) -> void:
	if SMOOTHING_ENABLED: _smooth_motion()

func _smooth_motion() -> void:
	global_rotation.y = HeadRoot.global_rotation.y
	global_rotation.z = HeadRoot.global_rotation.z
	global_position.x = HeadRoot.global_position.x
	global_position.z = HeadRoot.global_position.z
	var tween: Tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "global_position:y", HeadRoot.global_position.y, 0.1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
