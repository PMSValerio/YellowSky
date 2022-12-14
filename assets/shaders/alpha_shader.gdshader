shader_type canvas_item;

uniform float alpha : hint_range(0.0, 1.0, 0.1) = 1.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color.a = min(color.a, alpha);
	COLOR = color;
}