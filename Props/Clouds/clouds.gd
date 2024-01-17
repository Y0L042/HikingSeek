@tool
extends Node3D

@export_group("Cloud Settings")
@export var MeshesRoot: Node3D
@export var TransformModifier: Node3D
var _randomize_mesh_idx: bool = false
@export var randomize_mesh_idx: bool:
	get:
		return _randomize_mesh_idx
	set(value):
		_randomize_mesh_idx = value
		if value:
			selected_mesh_idx = _select_random_mesh_idx()
			_set_selected_mesh_visibility()
var _selected_mesh_idx: int = 0
@export var selected_mesh_idx: int:
	get:
		return _selected_mesh_idx
	set(value):
		_selected_mesh_idx = clampi(value, 0, 5 - 1)
		_set_selected_mesh_visibility()
var _randomize_mesh_transform: bool
@export var randomize_mesh_transform: bool:
	get:
		return _randomize_mesh_transform
	set(value):
		_randomize_mesh_transform = value
		if value:
			_randomize_selected_mesh_transform()
		else:
			_reset_meshes()
@export var random_scale_min: Vector3 = Vector3.ONE
@export var random_scale_max: Vector3 = Vector3.ONE
@export var random_rotation_min: Vector3 = Vector3.ZERO
@export var random_rotation_max: Vector3 = Vector3.ZERO

@export_group("Editor Tools")
@export var btn_refresh: bool:
	set(value):
		_refresh_meshes()
@export var btn_reset: bool:
	set(value):
		_reset_meshes()

var meshes_array: Array[MeshInstance3D]
var _base_meshes_array: Array[MeshInstance3D]
var _base_mesh_root_transform: Transform3D
var _base_transform_modifier_transform: Transform3D
var random_number_generator: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	random_number_generator.randomize()
	#random_number_generator.seed = 0
	_base_meshes_array = _refresh_meshes()
	if MeshesRoot:
		_base_mesh_root_transform = MeshesRoot.transform
	if TransformModifier:
		_base_transform_modifier_transform = TransformModifier.transform

func _refresh_meshes() -> Array[MeshInstance3D]:
	if MeshesRoot:
		meshes_array.clear()
		for child in MeshesRoot.get_children():
			if child is MeshInstance3D:
				meshes_array.append(child)
	return meshes_array
	_set_selected_mesh_visibility()

func _set_selected_mesh_visibility() -> void:
	for mesh_idx: int in len(meshes_array):
		meshes_array[mesh_idx].visible = mesh_idx == selected_mesh_idx

func _select_random_mesh_idx() -> int:
	return random_number_generator.randi_range(0, len(meshes_array) - 1)

func _randomize_selected_mesh_transform() -> void:
	var random_scale: Vector3 = Vector3(
				random_number_generator.randf_range(random_scale_min.x, random_scale_max.x),
				random_number_generator.randf_range(random_scale_min.y, random_scale_max.y),
				random_number_generator.randf_range(random_scale_min.z, random_scale_max.z)
			)
	var random_rotation: Vector3 = Vector3(
				deg_to_rad(random_number_generator.randf_range(random_rotation_min.x, random_rotation_max.x)),
				deg_to_rad(random_number_generator.randf_range(random_rotation_min.y, random_rotation_max.y)),
				deg_to_rad(random_number_generator.randf_range(random_rotation_min.z, random_rotation_max.z))
			)
	TransformModifier.scale = random_scale
	TransformModifier.rotation = random_rotation

func _reset_meshes() -> void:
	TransformModifier.transform = _base_mesh_root_transform
