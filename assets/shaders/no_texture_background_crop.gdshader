shader_type canvas_item;

uniform float horizon_y : hint_range(0.0, 1.0, 0.1) = 0.7;

void fragment() {
	if (SCREEN_UV.y < horizon_y) {
		COLOR.a = 0.0;
	}
}