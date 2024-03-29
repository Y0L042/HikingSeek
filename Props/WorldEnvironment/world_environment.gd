@tool
extends Node3D

@export_group("Node References")
@export var SkyEnvironment: WorldEnvironment
@export var SunMoon_ref: Node3D
@export var Sun: MeshInstance3D
@export var Moon: MeshInstance3D

@export_group("Settings")
@export_subgroup("Sky")


@export var use_time_of_day: bool:
	get:
		return use_time_of_day
	set(value):
		use_time_of_day = value
		#lbl_use_time_of_day
#@export var lbl_use_time_of_day: String:
	#get:
		#if use_time_of_day:
			#return "Time of Day"
		#else:
			#return "Degrees"

@export var time_of_day: float:
	get:
		return time_of_day
	set(value):
		value = wrapf(value, 0, 2400)
		time_of_day = value
		if use_time_of_day:
			sky_rotation = time_of_day/2400 *360

@export var sky_rotation: float:
	get:
		return sky_rotation
	set(value):
		value = wrapf(value, 0, 360)
		sky_rotation = value
		if !use_time_of_day:
			time_of_day = sky_rotation/360 *2400
		_set_sun_moon_rotation(value)


@export var use_live_time: bool = false
## 1 for real time
@export var minutes_per_day: float = 1440

@export var background_energy_multiplier: float = 1
@export var background_energy_min: float = 0.01

#region ColorSettings
@export_group("Color Settings")
@export_color_no_alpha var sky_top_color_day: Color
@export_color_no_alpha var sky_top_color_night: Color
@export_color_no_alpha var sky_horizon_color_day: Color
@export_color_no_alpha var sky_horizon_color_night: Color
#endregion ColorSettings

#region SunMoonSettings
@export_subgroup("Sun and Moon")
@export var sun_offset: float = 100:
	get:
		return sun_offset
	set(value):
		sun_offset = value
		if Sun:
			Sun.position.y = -value

@export var moon_offset: float = 100:
	get:
		return moon_offset
	set(value):
		moon_offset = value
		if Moon:
			Moon.position.y = value
#endregion SunMoonSettings
@export_group("Debug")
@export var DISABLE_EDITOR_MODE: bool = false
@export var clamp_cos_value: float

func _ready() -> void:
	_set_sun_moon_rotation(sky_rotation)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() and DISABLE_EDITOR_MODE: return
	if use_live_time: _set_real_time_sky(delta)
	_rotate_sky()

func _set_real_time_sky(delta: float) -> void:
		sky_rotation += delta*360 /60 /clampf(minutes_per_day, 0.001, INF)

func _rotate_sky() -> void:
	clamp_cos_value = clampf((-cos(deg_to_rad(sky_rotation)) + 1)/2, background_energy_min, INF)
	SkyEnvironment.environment.set_bg_energy_multiplier(clampf((-cos(deg_to_rad(sky_rotation)) + 1)/2 * background_energy_multiplier, background_energy_min, INF))
	SkyEnvironment.environment.sky.sky_material.sky_top_color = lerp(sky_top_color_night, sky_top_color_day,clampf((-cos(deg_to_rad(sky_rotation)) + 1)/2, background_energy_min, INF))
	SkyEnvironment.environment.sky.sky_material.sky_horizon_color = lerp(sky_horizon_color_night, sky_horizon_color_day,clampf((-cos(deg_to_rad(sky_rotation)) + 1)/2, background_energy_min, INF))
	SkyEnvironment.environment.sky.sky_material.sky_energy_multiplier = clampf((-cos(deg_to_rad(sky_rotation)) + 1)/2, background_energy_min, INF)
	SkyEnvironment.environment.fog_density = clampf((-cos(deg_to_rad(sky_rotation)) + 1)/2, background_energy_min, INF) * 0.1
	#SkyEnvironment.environment.volumetric_fog_density = clampf((-cos(deg_to_rad(sky_rotation)) + 1)/2, background_energy_min, INF) * 0.25

func _set_sun_moon_rotation(i_rotation: float) -> void:
	if SunMoon_ref:
		SunMoon_ref.rotation.x = (deg_to_rad(i_rotation))
