extends Area3D

@export var properties: Dictionary :
	get:
		return properties # TODOConverter40 Non existent get function
	set(new_properties):
		if(properties != new_properties):
			properties = new_properties
			update_properties()

func update_properties() -> void:
	pass

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body) -> void:
	if body.is_in_group("Entity_Player"):
		GDebug.print(self, ["Entered Climbable"])
		body.in_climbable_range = true

func _on_body_exited(body) -> void:
	if body.is_in_group("Entity_Player"):
		GDebug.print(self, ["Exited Climbable"])
		body.in_climbable_range = false


