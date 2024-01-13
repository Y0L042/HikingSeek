extends Node

@export var debug_panel_packedscene: PackedScene

#var panel: DebugPanelNode

func _ready() -> void:
	#if panel == null:
		#panel = DebugPanelNode.spawn(self)
	pass

#region Debug Print
enum ParamsColors {
	STANDARD,
	ORANGE,
	RED,
}

enum ThemeColors {
	STANDARD,
	ORANGE,
	GREEN,
}

enum ThemeStyles {
	STANDARD,
	ORANGE,
	GREEN,
}

func print(i_sender: Variant, i_params: Array, i_params_color: String = 'white', i_theme_color: ThemeColors = ThemeColors.STANDARD, i_theme_style: ThemeStyles = ThemeStyles.STANDARD) -> void:
	var _params_colors: Dictionary = {
		ParamsColors.STANDARD : 'white',
		ParamsColors.ORANGE : 'orange',
		ParamsColors.RED : 'red',
	}

	var theme_colors: Dictionary = {
		ThemeColors.STANDARD : ['white', 'gray', 'white'],
		ThemeColors.ORANGE : ['orange', 'orange', 'orange'],
		ThemeColors.GREEN : ['green', 'green', 'green'],
	}
	var theme_styles: Dictionary = {
		ThemeStyles.STANDARD : ['', ''],
		ThemeStyles.ORANGE : ['[b]', '[/b]'],
		ThemeStyles.GREEN : ['[b]', '[/b]']
	}

	var color_theme: ThemeColors = i_theme_color
	var style_theme: ThemeStyles = i_theme_style

	var sender_name: String
	if (i_sender != null):
		sender_name = '[i][color=%s]%s[/color][/i]' % [theme_colors[color_theme][0], i_sender.name]
	else:
		sender_name = '[i][color=%s]NULL_SENDER[/color][/i]' % [theme_colors[color_theme][0]]
	var location: Dictionary = get_stack()[1]
	var func_info: String = '[color=%s]%s @ %s()[/color]' % [theme_colors[color_theme][1], location.line, location.function]
	var pre_params: String = theme_styles[style_theme][0]
	var post_params: String = theme_styles[style_theme][1]

	var params_str: String = '[color=%s]' % i_params_color #params_colors[i_params_color]
	for param: Variant in i_params:
		params_str += ' ' + str(param)
	params_str += ' [/color]'

	var output: String = '%s [b] | [/b] %s [b]->[/b] %s%s%s' % [sender_name, func_info, pre_params, params_str, post_params]

	print_rich(output)
#endregion Debug Print
