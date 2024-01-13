class_name State_Player_InAir
extends PlayerStateClass

func enter() -> void:
	GDebug.print(player, ["Entered State_Player_InAir"])
	change_state(State_Player_InAir_Idle.new(node_parent, self))

func custom_process(_delta: float) -> void:
	super.custom_process(_delta)
	if player.is_on_ground():
		node_parent.change_state(State_Player_OnGround.new(node_parent, null))

func custom_physics_process(_delta: float) -> void:
	super.custom_physics_process(_delta)

func custom_unhandled_input(_event: InputEvent) -> void:
	super.custom_unhandled_input(_event)

func exit() -> void:
	pass
