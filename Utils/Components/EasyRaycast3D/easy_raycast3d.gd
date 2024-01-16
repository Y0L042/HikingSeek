@tool
extends RayCast3D

var _length: float
@export var length: float = 1 :
	get:
		return _length
	set(value):
		_length = value
		target_position = target_position.normalized() * _length
