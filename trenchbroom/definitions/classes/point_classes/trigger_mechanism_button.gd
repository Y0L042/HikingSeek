#@tool
extends Qodot_PointBaseEntity

signal trigger()

func _ready() -> void:
	super._ready()
	add_to_group("trigger")
	add_to_group("interactible")
	#base_transform = transform

func update_properties() -> void:
	super.update_properties()

func use(i_trigger_message: Dictionary) -> void:
	super.use({})
	trigger.emit({})

# HACK for testing purposes
# func _unhandled_input(event: InputEvent) -> void:
# 	if Input.is_action_just_pressed("player_interact"):
# 		use({})
# 		GDebug.print(self, ["Emit use()"], 'red')
