shader_type canvas_item;

uniform vec4 horizon_colour : hint_color = vec4(0.35, 0.2, 0.25, 1.0);

uniform float horizon_y : hint_range(0.0, 1.0, 0.1) = 0.7;

void fragment() {
	float above_horizon = SCREEN_UV.y - horizon_y;
	float halfway = (1.0 - horizon_y) / 2.0;
	
	float mix_value = (SCREEN_UV.y) * (-1.0) / (halfway);
	
	vec4 color = texture(TEXTURE, UV);
	//color.rgb = mix(color.rgb, horizon_colour.rgb, mix_value);
	//COLOR.rgb = color.rgb;
	
	if (SCREEN_UV.y < horizon_y) {
		COLOR.a = 0.0;
	}
}