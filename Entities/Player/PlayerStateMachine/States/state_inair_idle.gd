class_name State_Player_InAir_Idle
extends PlayerStateClass

func enter() -> void:
	GDebug.print(player, ["Entered State_Player_InAir_Idle"])
	pass

func custom_process(_delta: float) -> void:
	super.custom_process(_delta)
	if player.input_flag_is_moving:
		state_parent.change_state(State_Player_InAir_Move.new(node_parent, state_parent))
		pass

func custom_physics_process(_delta: float) -> void:
	super.custom_physics_process(_delta)
	player.apply_gravity(_delta)
	player.move(_delta, 0, player.MOVE_STATS.air_friction)

func custom_unhandled_input(_event: InputEvent) -> void:
	super.custom_unhandled_input(_event)

func exit() -> void:
	pass
