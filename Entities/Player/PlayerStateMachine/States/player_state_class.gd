class_name PlayerStateClass
extends StateClass

var player: CharacterBody3D
#var sm_action_comp: StateMachineActionComponent

func _init(i_node_parent: Variant, i_state_parent: StateClass) -> void:
	super._init(i_node_parent, i_state_parent)
	player = node_parent.player
	#sm_action_comp = node_parent.action_component
