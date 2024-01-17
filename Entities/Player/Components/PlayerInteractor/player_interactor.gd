extends Node3D

@export var node_root: Node3D
@export var Interact_Raycast: RayCast3D
@export var Pickup_Container: Node3D
@export var throw_force:float = 10
@export var MAX_HOLD_DISTANCE_SQRD: float

var pickedup_object: Node3D = null

func _ready() -> void:
	if is_zero_approx(MAX_HOLD_DISTANCE_SQRD):
		MAX_HOLD_DISTANCE_SQRD = (Interact_Raycast.target_position - Interact_Raycast.position).length_squared()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("player_pickup"):
		if !pickedup_object:
			pick_up_object()
		else: drop_object()
	if pickedup_object and Input.is_action_just_pressed('player_interact'):
		throw_object()

func _physics_process(delta: float) -> void:
	if pickedup_object:
		var dist_sqrd: float = (pickedup_object.global_position - Interact_Raycast.global_position).length_squared()
		if dist_sqrd > MAX_HOLD_DISTANCE_SQRD:
			drop_object()

func pick_up_object() -> void: # TODO make modular
	if !pickedup_object:
		Interact_Raycast.force_raycast_update()
		if Interact_Raycast.is_colliding():
			var node: Variant = Interact_Raycast.get_collider()
			if node.is_in_group(GRef.GROUP_INTERACTIBLE_PICKUPABLE):
				GDebug.print(self, ["Pick Up", node])
				pickedup_object = node
				_get_PickUpAble_child(pickedup_object).hold(node_root, drop_object, Pickup_Container)

func drop_object() -> void:
	if pickedup_object:
		_get_PickUpAble_child(pickedup_object).drop()
		pickedup_object = null

func throw_object() -> void:
	if pickedup_object:
		var dir: Vector3 = - Interact_Raycast.global_transform.basis.z
		_get_PickUpAble_child(pickedup_object).throw(dir, throw_force)
		pickedup_object = null

func _get_PickUpAble_child(i_node: Node3D) -> PickUpAble:
	for child in i_node.get_children():
		if child is PickUpAble:
			return child
	return null