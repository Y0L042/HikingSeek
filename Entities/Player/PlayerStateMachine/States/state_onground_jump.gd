class_name State_Player_OnGround_Jump
extends PlayerStateClass

func enter() -> void:
	GDebug.print(player, ["Entered State_Player_OnGround_Jump"])
	player.jump()

# func custom_process(delta: float) -> void:
# 	super.custom_process(delta)

# func custom_physics_process(delta: float) -> void:
# 	super.custom_physics_process(delta)
# 	if player.body_flag_on_ground:
# 		# HACK I am going to move the player up while it is on ground
# 		#sm_action_comp.state_onground_jump_physproc(delta)
# 		pass

# func custom_unhandled_input(_event: InputEvent) -> void:
# 	super.custom_unhandled_input(_event)

# func exit() -> void:
# 	pass
