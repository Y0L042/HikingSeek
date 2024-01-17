@tool
extends Node3D

func _ready() -> void:
	if !Engine.is_editor_hint():
		queue_free()


