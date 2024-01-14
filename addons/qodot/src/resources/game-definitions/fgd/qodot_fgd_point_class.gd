@tool
class_name QodotFGDPointClass
extends QodotFGDClass

func _init():
	prefix = "@PointClass"

	#Y0L042 Modifications
	force_fix_packedscene()

# The scene file to associate with this PointClass
# On building the map, this scene will be instanced into the scene tree
@export_group ("Scene")
var _scene_file_path: String #Y0L042 Modifications
@export var scene_file_path: String:
	get:
		return _scene_file_path
	set(value):
		_scene_file_path = value
		force_fix_packedscene()
var _scene_file: PackedScene #Y0L042 Modifications
@export var scene_file: PackedScene:
	get:
		if scene_file_path:
			return load(scene_file_path)
		else:
			return null

# The script file to associate with this PointClass
# On building the map, this will be attached to any brush entities created
# via this classname if no scene_file is specified
@export_group ("Scripting")
@export var script_class: Script

@export_group("Build")
## Entity will use `angles`, `mangle`, or `angle` to determine rotations on QodotMap build, prioritizing the key value pairs in that order.
@export var apply_rotation_on_map_build := true

#Y0L042 Modifications
func force_fix_packedscene() -> void:
	if scene_file_path:
		if scene_file:
			scene_file.take_over_path(scene_file_path)
		else:
			scene_file = load(scene_file_path)
