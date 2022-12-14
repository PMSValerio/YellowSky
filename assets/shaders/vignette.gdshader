shader_type canvas_item;

uniform vec4 colour : hint_color = vec4(0.36, 0.26, 0.35, 1.0);
uniform float multiplier = 0.2;
uniform float softness = 0.7;

void fragment() {
	
	float dist_from_center = distance(SCREEN_UV, vec2(0.5));
	float alpha = COLOR.a;
	alpha = dist_from_center;
	COLOR = vec4(colour.rgb, alpha);
	COLOR = vec4(colour.rgb, smoothstep(multiplier, softness, dist_from_center));
}