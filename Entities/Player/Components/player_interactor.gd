extends Node3D

@export var node_root: Node3D
@export var Interact_Raycast: RayCast3D
@export var Pickup_Container: Node3D

var pickedup_object: Node3D = null

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("player_pickup"):
		pick_up()

func pick_up() -> void: # TODO make modular
	if !pickedup_object:
		pass
	Interact_Raycast.force_raycast_update()
	if Interact_Raycast.is_colliding():
		var node: Variant = Interact_Raycast.get_collider()
		if node.is_in_group(GRef.GROUP_INTERACTIBLE_PICKUPABLE):
			GDebug.print(self, ["Pick Up this object: ", node])
			pickedup_object = node
			pickedup_object.PickUpAble_Component.hold(node_root, Pickup_Container)