extends StateMachineHandler

var player: CharacterBody3D

func _ready() -> void:
	super._ready()
	player = node_root as Entity_Player
	change_state(State_Player_OnGround.new(self, null))
