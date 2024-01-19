@tool
extends Node3D

@export var ammo_packedscene_path: String:
	get:
		return ammo_packedscene_path
	set(value):
		ammo_packedscene_path = value
		if value:
			ammo_packedscene = load(value)
@export var ammo_packedscene: PackedScene
@export var muzzle_target: Node3D

@export var firing_mode: FiringMode = FiringMode.SEMI
@export var firing_rate_rpm: float = 60

var ready_to_fire: bool = true

enum FiringMode {
	SEMI,
	FULL
}

func _physics_process(delta: float) -> void:
	if firing_mode == FiringMode.SEMI:
		if Input.is_action_just_pressed('player_primary_action'):
			if ready_to_fire:
				_on_primary_action_executed(self) # TODO fix the actor reference
	if firing_mode == FiringMode.FULL:
		if Input.is_action_pressed('player_primary_action'):
			if ready_to_fire:
				_on_primary_action_executed(self) # TODO fix the actor reference

func _on_primary_action_executed(actor: Variant) -> void:
	if !ready_to_fire: return
	var bullet: Variant = _spawn_packedscene(ammo_packedscene) as Variant
	GDebug.print(self, ["bullet ", bullet])
	bullet._on_fired(-global_transform.basis.z)
	ready_to_fire = false
	get_tree().create_timer(60/firing_rate_rpm).timeout.connect(func(): ready_to_fire = true)

func _spawn_packedscene(i_pckscene: PackedScene) -> Node:
	if !i_pckscene.can_instantiate(): return null
	var node: Node = i_pckscene.instantiate()
	get_tree().get_root().add_child(node)
	node.global_position = muzzle_target.global_position
	return node
