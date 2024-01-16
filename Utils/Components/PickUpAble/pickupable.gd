extends Node3D

@export_group("Carriable Settings")
@export var node_root: RigidBody3D
@export var collision_shape: CollisionShape3D
@export var interaction_text : String = "Carry"
@export var pick_up_sound : AudioStream
@export var drop_sound : AudioStream
@export var audio_stream_player_3d: AudioStreamPlayer3D

var is_being_carried: bool
var holder: Entity

func carry(entity: Entity) -> void:
	holder = entity
	if is_being_carried:
		leave()
	else:
		hold()

func _process(delta: float) -> void:
	if is_being_carried:
		be_carried(delta)

func be_carried(delta: float) -> bool:
	var dist_exceeded: bool = false
	global_position = holder.carryable_position.global_position
	global_rotation = holder.carryable_position.global_rotation
	return dist_exceeded

func hold() -> void:
	collision_shape.set_disabled(true)
	holder.carried_object = node_root
	# Play Pick up sound.
	if pick_up_sound != null:
		if audio_stream_player_3d:
			audio_stream_player_3d.stream = pick_up_sound
			audio_stream_player_3d.play()
	node_root.set_sleeping(true)
	is_being_carried = true

func leave() -> void:
	collision_shape.set_disabled(false)
	holder.carried_object = null
	node_root.set_sleeping(false)
	is_being_carried = false

func throw(direction: Vector3, power: float) -> void:
	leave()
	if drop_sound != null:
		if audio_stream_player_3d:
			audio_stream_player_3d.stream = drop_sound
			audio_stream_player_3d.play()
	node_root.apply_central_impulse(direction * Vector3(power, power, power))

func pick_up_object() -> void:
	pass