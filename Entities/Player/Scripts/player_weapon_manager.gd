extends Node3D

@export var node_root: Node3D
@export var weapon: Node3D

func _unhandled_input(event: InputEvent) -> void:
	#if Input.is_action_pressed('player_primary_action'):
		#if weapon: weapon._on_primary_action_executed(node_root)
		pass
