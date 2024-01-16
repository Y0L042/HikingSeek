class_name Interactible
extends Area3D

@export_group("Node References")
@export var node_root: Node3D

signal interacted
signal focused
signal unfocused

func _init() -> void:
	add_to_group('interactible')
