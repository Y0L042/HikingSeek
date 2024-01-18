@tool
extends FogVolume

@export var density: float:
	get:
		return density
	set(value):
		density = value
		material.density = density

@export var density_noise: FastNoiseLite

@export var offset_y: float:
	get:
		return offset_y
	set(value):
		offset_y = value
		material.density_texture.noise.offset.y = offset_y

var delta_time: float = 0

func _physics_process(delta: float) -> void:
	delta_time += delta*20
	offset_y = (-cos(deg_to_rad(delta_time)) + 1)/2 * 100
	density = (-cos(deg_to_rad(delta_time)) + 1)/2 *1.5 +0.25
