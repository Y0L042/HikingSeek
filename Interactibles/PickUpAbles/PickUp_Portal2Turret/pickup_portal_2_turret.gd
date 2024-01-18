extends RigidBody3D

@export var audiostreamplayer: AudioStreamPlayer3D
@export var pickup_audiostream_array: Array[AudioStream]
@export var thrown_audiostream_array: Array[AudioStream]
@export var fallingover_audiostream_array: Array[AudioStream]

var fallingover_audiostream_emitted: bool = false

func _physics_process(delta: float) -> void:
	_on_upright()
	_on_falling_over()

func _on_falling_over() -> void:
	if !fallingover_audiostream_emitted:
		if audiostreamplayer.playing:
			await get_tree().create_timer(2).timeout
			return
		if global_transform.basis.y.dot(Vector3.UP) < 0.307 and linear_velocity.length_squared() < 2*2 and angular_velocity.length_squared() < 5*5:
			if fallingover_audiostream_array.is_empty(): return
			GDebug.print(self, ["playing sound: falling over"])
			audiostreamplayer.stream = _select_random_audiostream(fallingover_audiostream_array)
			audiostreamplayer.play()
			fallingover_audiostream_emitted = true

func _on_upright() -> void:
	if global_transform.basis.y.dot(Vector3.UP) > 0.808 and fallingover_audiostream_emitted:
		GDebug.print(self, ["upright"])
		fallingover_audiostream_emitted = false

func _select_random_audiostream(i_audiostream_array: Array[AudioStream]) -> AudioStream:
	var idx: int = randi_range(0, len(i_audiostream_array)-1)
	return i_audiostream_array[idx]

func _on_pick_up_able_pickedup(i_holder: Variant) -> void:
	if pickup_audiostream_array.is_empty(): return
	audiostreamplayer.stream = _select_random_audiostream(pickup_audiostream_array)
	audiostreamplayer.play()

func _on_pick_up_able_thrown(i_holder: Variant) -> void:
	if audiostreamplayer.playing: await get_tree().create_timer(0.25).timeout
	if thrown_audiostream_array.is_empty(): return
	audiostreamplayer.stream = _select_random_audiostream(thrown_audiostream_array)
	await get_tree().create_timer(0.1).timeout
	audiostreamplayer.play()
