@tool
class_name AMMO_Base_Grapple_Projectile
extends RigidBody3D

@export var linear_firing_force: float = 25

var is_fired: bool = false
var fired_direction: Vector3

func _on_fired(i_direction: Vector3) -> void:
	is_fired = true
	fired_direction = i_direction.normalized()
	apply_central_impulse(fired_direction * linear_firing_force)
