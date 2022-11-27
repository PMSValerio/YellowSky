shader_type canvas_item;

uniform vec4 horizon_colour : hint_color = vec4(0.35, 0.2, 0.25, 1.0);
uniform float dim_amount : hint_range(0.0, 1.0, 0.1) = 0.3;
uniform float horizon_y : hint_range(0.0, 1.0, 0.1) = 0.7;

void fragment() {
	float above_horizon = SCREEN_UV.y - horizon_y;
	float halfway = (1.0 - horizon_y) * dim_amount + horizon_y;
	float full_dimmed = horizon_y / 3.0;
	
	float mix_value = clamp(1.0 + (-1.0)/(halfway-horizon_y) * (SCREEN_UV.y - horizon_y), 0.0, 1.0);
	
	vec4 color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0);
	color.rgb = mix(color.rgb, horizon_colour.rgb, mix_value);
	
	if (SCREEN_UV.y < horizon_y) {
		color.a = 0.0;
	}
	else {
		color.a = color.a;
	}
	COLOR = color;
}