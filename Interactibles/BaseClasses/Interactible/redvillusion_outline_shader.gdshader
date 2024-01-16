shader_type spatial;
render_mode unshaded, cull_front;

uniform bool enabled = true;
uniform float border_width : hint_range(0,1,0.001) = 0.1;
uniform vec4 color : source_color = vec4(1.0);

uniform bool pattern;
uniform float line_number : hint_range(0,100,1);
uniform float line_sharpness : hint_range(0,10,0.001);

uniform bool pulse;
uniform float pulse_speed : hint_range(0,100,1);

uniform bool line_movement;
uniform float line_movement_speed : hint_range(-100,100,1);

uniform bool wave;

void vertex() {
	if (enabled)
	{
		VERTEX += VERTEX * border_width;
	}
}

void fragment() {
	if (enabled)
	{
		ALBEDO = color.rgb; // Use .rgb instead of .xyz for color vectors

		if (pattern)
		{
			vec2 uv = VERTEX.xy * line_number;
			float pattern_value = sin(dot(uv, vec2(1.0))); // Simplified the sin calculation

			if (pulse)
			{
				ALBEDO = pattern_value * line_sharpness * color.rgb * abs(sin(TIME * pulse_speed));
			}
			else if (line_movement)
			{
				ALBEDO = pattern_value * line_sharpness * color.rgb;
			}
			else
			{
				ALBEDO = pattern_value * line_sharpness * color.rgb;
			}
		}

		if (wave)
		{
			vec2 uv = VERTEX.xy * line_number;
			ALBEDO = sin(uv.x + TIME * line_movement_speed) * line_sharpness * color.rgb;
		}
	}
}
