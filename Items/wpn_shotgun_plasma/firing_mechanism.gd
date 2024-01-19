class_name FiringMechanism
extends Node3D

@export_group("Node References")
@export var node_root: Node3D

var actor: Variant

signal primary_action_executed
signal secondary_action_executed
signal enter_aim_action_executed
signal exit_aim_action_executed
signal reload_action_executed

func _ready() -> void:
	add_to_group(GRef.GROUP_ITEM_WEAPON)
	if node_root:
		node_root.add_to_group(GRef.GROUP_ITEM_WEAPON)

func execute_primary_action(i_actor: Variant) -> void:
	actor = i_actor
	primary_action_executed.emit(actor)
	GDebug.print(node_root, ["interacted"], 'red')

func execute_secondary_action(i_actor: Variant) -> void:
	actor = i_actor
	secondary_action_executed.emit(actor)

func execute_enter_aim_action(i_actor: Variant) -> void:
	actor = i_actor
	enter_aim_action_executed.emit(actor)

func execute_exit_aim_action(i_actor: Variant) -> void:
	actor = i_actor
	exit_aim_action_executed.emit(actor)

func execute_reload_action(i_actor: Variant) -> void:
	actor = i_actor
	reload_action_executed.emit(actor)
