#@tool
class_name Qodot_PointBaseEntity
extends Node3D

@export var properties: Dictionary :
	get:
		return properties # TODOConverter40 Non existent get function
	set(new_properties):
		if(properties != new_properties):
			properties = new_properties
			update_properties()

var base_transform: Transform3D
var stick_to_surface: bool = true

func _ready() -> void:
	add_to_group("qodot_pointentity")
	base_transform = transform

func update_properties() -> void:
	base_transform = transform
	if 'rotation' in properties:
		var tmp_transform: Transform3D = base_transform
		tmp_transform = tmp_transform.rotated_local(Vector3.UP, deg_to_rad(properties.rotation.y))
		tmp_transform = tmp_transform.rotated_local(Vector3.RIGHT, deg_to_rad(properties.rotation.x))
		tmp_transform = tmp_transform.rotated_local(Vector3.FORWARD, deg_to_rad(properties.rotation.z))
		transform = tmp_transform
	if 'scale' in properties:
		if !is_zero_approx(properties.scale):
			scale = Vector3.ONE * properties.scale
	if 'stick_to_surface' in properties:
		stick_to_surface = properties.stick_to_surface

func use(i_trigger_message: Dictionary) -> void:
	pass

func _stick_to_surface() -> void:
	print("-------------------------------------------------------------")
	print("Entity: ", self)
	var pos: Vector3 = global_position
	var down_dir: Vector3 = (transform.basis * Vector3.DOWN).normalized()
	var length: float = 100
	var target: Vector3 = pos + down_dir * length
	await get_tree().create_timer(1).timeout
	var result: Qodot_IntersectRayResults = qodot_do_raycast_point_to_point(
				get_tree().get_root(),
				pos,
				target,
			)
	print("positive_result: ", result.positive_results)
	print("result_pos: ", result.position)
	if result.positive_results:
		position = result.position

func qodot_do_raycast_point_to_point(
		i_context: Object,
		i_origin: Vector3,
		i_target: Vector3,
		i_rid_exeptions: Array[RID] = [],
		i_col_mask: int = 0xFFFFFFFF
	) -> Qodot_IntersectRayResults:
	var space_state: PhysicsDirectSpaceState3D = i_context.get_tree().get_root().get_world_3d().direct_space_state
	if Engine.is_editor_hint():
		var editor_root = get_tree().edited_scene_root
		space_state = editor_root.get_world_3d().direct_space_state
		print("editor_root: ", editor_root)
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(i_origin, i_target)
	if i_rid_exeptions:
		query.exclude = i_rid_exeptions
	query.collision_mask = i_col_mask
	var results_dict: Dictionary = space_state.intersect_ray(query)
	var result: Qodot_IntersectRayResults = Qodot_IntersectRayResults.new(results_dict)
	return result


class Qodot_IntersectRayResults:
	var positive_results: bool
	var collider: Variant
	var collider_id: Variant
	var normal: Vector3
	var position: Vector3
	var face_index: int
	var rid: Variant
	var shape: Variant

	func _init(i_results_dict: Dictionary) -> void:
		if i_results_dict.is_empty():
			positive_results = false
			return
		positive_results = true
		collider = i_results_dict.collider
		collider_id = i_results_dict.collider_id
		normal = i_results_dict.normal
		position = i_results_dict.position
		if 'index' in i_results_dict:
			face_index = i_results_dict.index
		rid = i_results_dict.rid
		shape = i_results_dict.shape
