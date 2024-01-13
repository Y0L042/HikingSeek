@icon('res://Utils/StateMachine/icons/state_icon.png')
class_name StateClass
extends Node3D

var node_parent: Variant
var state_parent: StateClass
var current_state: StateClass

func _init(i_node_parent: Variant, i_state_parent: StateClass) -> void:
	node_parent = i_node_parent
	state_parent = i_state_parent

func _ready() -> void:
	add_to_group("state")

func enter() -> void:
	pass

func custom_process(_delta: float) -> void:
	if current_state: current_state.custom_process(_delta)

func custom_physics_process(_delta: float) -> void:
	if current_state: current_state.custom_physics_process(_delta)

func custom_unhandled_input(_event: InputEvent) -> void:
	if current_state: current_state.custom_unhandled_input(_event)

func exit() -> void:
	pass

func change_state(i_new_state: StateClass) -> void:
	if current_state: current_state.exit();
	current_state = i_new_state
	if current_state: current_state.enter()
