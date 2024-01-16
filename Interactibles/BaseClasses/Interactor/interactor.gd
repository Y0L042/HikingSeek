class_name Interactor
extends Area3D

func _init() -> void:
	add_to_group('interactor')

func interact(i_interactible: Interactible) -> void:
	i_interactible.interacted.emit(self)

func focus(i_interactible: Interactible) -> void:
	i_interactible.focused.emit(self)

func unfocus(i_interactible: Interactible) -> void:
	i_interactible.unfocused.emit(self)

func get_closest_interactible() -> Interactible:
	var list: Array[Area3D] = get_overlapping_areas()
	var distance_squared: float
	var closest_distance_squared: float = INF
	var closest_interactible: Interactible = null
	for interactible in list:
		distance_squared = interactible.global_position.distance_squared_to(global_position)
		if distance_squared < closest_distance_squared:
			closest_interactible = interactible as Interactible
			closest_distance_squared = distance_squared
	return closest_interactible
