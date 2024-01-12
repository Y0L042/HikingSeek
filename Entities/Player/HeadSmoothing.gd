extends Marker3D

@export var FollowTarget: Node3D
@export var SmoothingTarget: Node3D
@export var SMOOTHING_FACTOR: float = 1

var offset: Vector3

func _ready() -> void:
	offset = position

func _physics_process(delta: float) -> void:
	#position.x = FollowTarget.global_position.x + offset.x
	#position.z = FollowTarget.global_position.z + offset.z
	#position.y = lerp(position.y, FollowTarget.position.y + offset.y, SMOOTHING_FACTOR * delta)
	position.y = move_toward(position.y, 1.8, SMOOTHING_FACTOR * delta)
	SmoothingTarget.position.y = global_position.y

