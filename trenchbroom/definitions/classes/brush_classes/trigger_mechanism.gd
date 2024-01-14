extends Area3D

var trigger_message: Dictionary = {}

signal trigger()

func _ready():
	add_to_group("trigger")
	body_entered.connect(handle_body_entered)
	body_exited.connect(handle_body_exited)

func handle_body_entered(body: Node):
	if body is StaticBody3D:
		return
	trigger_message["entered"] = true
	trigger.emit(trigger_message)

func handle_body_exited(body: Node):
	if body is StaticBody3D:
		return
	trigger_message["entered"] = false
	trigger.emit(trigger_message)
