class_name MovementStatsResource
extends Resource

@export_group("Movement Values")

@export_subgroup("Ground Movement")
@export_range(0, 10, 0.1) var ground_walk_speed: float = 5
@export_range(0, 20, 0.1) var ground_run_speed: float = 7.5
@export_range(0, 45, 0.1) var ground_sprint_speed: float = 12.5
@export_range(0, 100, 0.1) var ground_acceleration: float = 45
@export_range(0, 100, 0.1) var ground_friction: float = 35
@export_range(0, 100, 0.5) var ground_jump_force: float = 5

@export_subgroup("Air Movement")
@export_range(-50, 50, 0.1) var air_fall_speed: float = 19.62
@export_range(0, 20, 0.1) var air_move_speed: float = 7
@export_range(0, 100, 0.1) var air_acceleration: float = 20
@export_range(0, 100, 0.1) var air_friction: float = 15
@export_range(-10, 10, 0.01) var gravity_force: float = 9.81 # BUG does not set to automatically ProjectSettings.get_setting("physics/3d/default_gravity")
@export_range(0, 5, 0.1) var gravity_modifier: float = 1