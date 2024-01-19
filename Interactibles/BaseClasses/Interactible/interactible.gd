class_name Interactible
extends Area3D

@export_group("Node References")
@export var node_root: Node3D

var interactor: Variant

signal interacted
signal focused
signal unfocused

func _ready() -> void:
	add_to_group(GRef.GROUP_INTERACTIBLE_OBJECT)
	if node_root:
		node_root.add_to_group(GRef.GROUP_INTERACTIBLE_OBJECT)

func interact(i_interactor: Variant) -> void:
	interacted.emit(interactor)
	interactor = i_interactor
	GDebug.print(node_root, ["interacted"], 'red')

func focus(i_interactor: Variant) -> void:
	focused.emit(i_interactor)
	GDebug.print(node_root, ["focused"], 'green')

func unfocus(i_interactor: Variant) -> void:
	unfocused.emit(i_interactor)
	GDebug.print(node_root, ["unfocused"], 'blue')
