extends CharacterBody3D

@export var properties: Dictionary :
	get:
		return properties # TODOConverter40 Non existent get function
	set(new_properties):
		if(properties != new_properties):
			properties = new_properties
			update_properties()

var offset_transform: Transform3D
var open_on_collision: bool = false
var speed: float = 1.0
var auto_close: bool = true
var auto_close_timer: float = 5

var base_transform: Transform3D
var target_transform: Transform3D

var is_open: bool = false

func _ready() -> void:
	add_to_group("mechanism")
	base_transform = transform
	target_transform = base_transform
	if open_on_collision:
		_create_area()

func _process(delta: float) -> void:
	# transform = transform.interpolate_with(target_transform, speed * delta)
	pass

func update_properties() -> void:
	if 'translation' in properties:
		offset_transform.origin = properties.translation
	if 'rotation' in properties:
		offset_transform.basis = offset_transform.basis.rotated(Vector3.RIGHT, properties.rotation.x)
		offset_transform.basis = offset_transform.basis.rotated(Vector3.UP, properties.rotation.y)
		offset_transform.basis = offset_transform.basis.rotated(Vector3.FORWARD, properties.rotation.z)
	if 'scale' in properties:
		offset_transform.basis = offset_transform.basis.scaled(properties.scale)
	if 'speed' in properties:
		speed = properties.speed
	if 'open_on_collision' in properties:
		open_on_collision = properties.open_on_collision
	if 'auto_close' in properties:
		auto_close = properties.auto_close
	if 'auto_close_timer' in properties:
		auto_close_timer = properties.auto_close_timer

func use(i_trigger_message: Dictionary) -> void:
	var should_open: bool
	if "entered" in i_trigger_message:
		should_open = i_trigger_message.entered
		if should_open: play_motion()
		if !should_open:
			await get_tree().create_timer(3, false, true).timeout # pause before closing
			reverse_motion()
	else:
		toggle_door_open()
		GDebug.print(self, ["activated"], 'green')

func toggle_door_open() -> void:
	if !is_open:
		play_motion()
	else:
		await get_tree().create_timer(3, false, true).timeout # pause before closing
		reverse_motion()

func play_motion() -> void:
	GDebug.print(self, ["Open Door"], 'orange')
	is_open = true
	var mechanism_tween: Tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	mechanism_tween.tween_property(self, "transform", base_transform * offset_transform, speed).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	if auto_close:
		await get_tree().create_timer(auto_close_timer, false, true).timeout # auto close timer
		reverse_motion()

func reverse_motion() -> void:
	GDebug.print(self, ["Close Door"], 'red')
	is_open = false
	var mechanism_tween: Tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	mechanism_tween.tween_property(self, "transform", base_transform, speed).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func on_body_entered(body: Node3D) -> void:
	play_motion()
	GDebug.print(self, ["Body:", body])

func _create_area() -> void:
	var area: Area3D = Area3D.new()
	add_child(area)
	area.body_entered.connect(on_body_entered)
	area.collision_layer = 0
	area.collision_mask = 0b110
	var colshape: CollisionShape3D = _find_collision_shape().duplicate()
	area.add_child(colshape)
	area.transform = area.transform.scaled_local(Vector3.ONE * 1.25)
	GDebug.print(self, ["area created"], 'red')

func _find_collision_shape() -> CollisionShape3D:
	for child in get_children():
		if child is CollisionShape3D:
			return child
	return null
