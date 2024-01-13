@icon('res://Utils/StateMachine/icons/sm_icon.png')
class_name StateMachineHandler
extends Node

@export var node_root: Node

var current_state: StateClass

func _ready() -> void:
	add_to_group("handler")

func _process(_delta: float) -> void:
	if current_state: current_state.custom_process(_delta)

func _physics_process(_delta: float) -> void:
	if current_state: current_state.custom_physics_process(_delta)

func _unhandled_input(_event: InputEvent) -> void:
	if current_state: current_state.custom_unhandled_input(_event)

func change_state(i_new_state: StateClass) -> void:
	if current_state: current_state.exit();
	current_state = i_new_state
	if current_state: current_state.enter()
