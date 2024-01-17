extends Area3D

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body):
	if body.is_in_group("Entity_Player"):
		GDebug.print(self, ["Entered Climbable"])
		body.in_climbable_range = true

func _on_body_exited(body):
	if body.is_in_group("Entity_Player"):
		GDebug.print(self, ["Exited Climbable"])
		body.in_climbable_range = false
