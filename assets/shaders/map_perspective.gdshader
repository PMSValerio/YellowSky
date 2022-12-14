shader_type canvas_item;

uniform vec4 horizon_colour : hint_color = vec4(0.35, 0.2, 0.25, 1.0);

uniform float horizon_y : hint_range(0.0, 1.0, 0.1) = 0.7;
uniform float stretch_factor = 0.4;

void fragment() {
	vec2 screen_uv = SCREEN_UV;
	
	float p, yy, xx, d;
	
	float a = 1.0;
	float b = stretch_factor;
	float h = horizon_y;
	
	p = (a * horizon_y) / (a - b);
	
	yy = screen_uv.y * b * horizon_y;
	yy = yy / (a * horizon_y + screen_uv.y * (b - a));
	
	//xx = (screen_uv.x / p) * (p - yy);
	xx = (screen_uv.x / p) * (p - (h - yy));
	
	//d = (a * yy) / (2.0 * p);
	d = (a * (h - yy)) / (2.0 * p);
	
	screen_uv = vec2(d + xx, yy);
	
	COLOR = textureLod(SCREEN_TEXTURE, screen_uv, 0.0);
	
	float mix_value = (SCREEN_UV.y - horizon_y / 2.0) * (1.0) / (horizon_y - horizon_y / 2.0);
	vec4 color = COLOR;
	color.rgb = mix(color.rgb, horizon_colour.rgb, mix_value);
	COLOR.rgb = color.rgb;
}