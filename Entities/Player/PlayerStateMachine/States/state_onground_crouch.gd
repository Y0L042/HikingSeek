class_name State_Player_OnGround_Crouch
extends PlayerStateClass

func enter() -> void:
	GDebug.print(player, ["Entered State_Player_OnGround_Crouch"])
	player.enter_crouch()
	pass

func custom_process(_delta: float) -> void:
	super.custom_process(_delta)
	if !player.test_exit_crouch(): return
	if player.input_flag_sprint:
		state_parent.change_state(State_Player_OnGround_Sprint.new(node_parent, state_parent))

func custom_physics_process(_delta: float) -> void:
	super.custom_physics_process(_delta)
	player.move(_delta, player.MOVE_STATS.ground_walk_speed, player.MOVE_STATS.ground_acceleration)

func custom_unhandled_input(_event: InputEvent) -> void:
	super.custom_unhandled_input(_event)

func exit() -> void:
	player.exit_crouch()
