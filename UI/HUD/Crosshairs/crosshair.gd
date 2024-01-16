extends Control


@onready var root: Control = %Root
@onready var lines_root: Node2D = %LinesRoot

@export var crosshair_color: Color = Color(1.0, 1.0, 1.0, 1.0)
func set_crosshair_color(value):
	set_line_color.call_deferred(value)

@export var crosshair_scale: float = 1.0
func set_crosshair_scale(value):
	set_lines_root_scale.call_deferred(value)

@export var crosshair_spread: float = 0.0
func set_crosshair_spread(value):
	change_line_spread.call_deferred(value)

@export var croshair_thickness: float = 1.0
func set_croshair_thickness(value):
	var thickness: float = value * (1/crosshair_scale)
	change_line_width.call_deferred(thickness)

var crosshair_spread_delta: float = 0.0 :
	set(value):
		set_crosshair_spread(crosshair_spread + value - crosshair_spread)
		crosshair_spread_delta = value


#region Default State Variables
var lines_root_scale: Vector2
var default_crosshair_color: Color
var default_crosshair_spread: float
var lineE_pos: Vector2
var lineS_pos: Vector2
var lineN_pos: Vector2
var lineW_pos: Vector2
var dot_pos: Vector2
var lineE_width: float
var lineS_width: float
var lineN_width: float
var lineW_width: float
var dot_scale: Vector2
#endregion Default State Variables

@onready var lineE: Line2D = $Root/LinesRoot/Line2D_1
@onready var lineS: Line2D = $Root/LinesRoot/Line2D_2
@onready var lineN: Line2D = $Root/LinesRoot/Line2D_3
@onready var lineW: Line2D = $Root/LinesRoot/Line2D_4
@onready var dot: Line2D = $Root/LinesRoot/Dot
@onready var line_array: Array[Line2D] = [lineE, lineS, lineN, lineW]

# @onready var crosshair_spread_tween: Tween = get_tree().create_tween()
func change_crosshair_spread(i_spread_delta: float, i_duration: float = 0.5) -> void:
	var crosshair_spread_tween: Tween = get_tree().create_tween()
	crosshair_spread_tween.tween_property(self, 'crosshair_spread_delta', i_spread_delta, i_duration)

func reset_crosshair_spread(i_duration: float = 0.2) -> void:
	change_crosshair_spread(0, i_duration)

func _ready() -> void:
	set_line_color(crosshair_color)
	save_default_crosshair_state()
	set_crosshair_color(crosshair_color)
	set_crosshair_scale(crosshair_scale)
	set_crosshair_spread(crosshair_spread)
	set_croshair_thickness(croshair_thickness)
	crosshair_spread_delta = 0.0


func save_default_crosshair_state() -> void:
	lines_root_scale = lines_root.scale
	default_crosshair_color = crosshair_color
	default_crosshair_spread = crosshair_spread
	lineE_pos = lineE.position
	lineS_pos = lineS.position
	lineN_pos = lineN.position
	lineW_pos = lineW.position
	dot_pos = dot.position
	lineE_width = lineE.width
	lineS_width = lineS.width
	lineN_width = lineN.width
	lineW_width = lineW.width
	dot_scale = dot.scale


func change_line_spread_relative(i_spread_delta: float) -> void:
	lineE.position.x += i_spread_delta
	lineS.position.y += i_spread_delta
	lineN.position.y += -i_spread_delta
	lineW.position.x += -i_spread_delta


func change_line_spread(i_spread: float) -> void:
	lineE.position.x = i_spread + lineE_pos.x
	lineS.position.y = i_spread + lineS_pos.y
	lineN.position.y = -i_spread + lineN_pos.y
	lineW.position.x = -i_spread + lineW_pos.x


func change_line_width(i_width: float) -> void:
	lineE.width = i_width * lineE_width
	lineS.width = i_width * lineS_width
	lineN.width = i_width * lineN_width
	lineW.width = i_width * lineW_width
	dot.scale = i_width * dot_scale


func set_line_color(i_color: Color) -> void:
	lineE.default_color = i_color
	lineS.default_color = i_color
	lineN.default_color = i_color
	lineW.default_color = i_color
	dot.default_color = i_color


func set_lines_root_scale(i_scale: float) -> void:
	lines_root.scale = i_scale * lines_root_scale
