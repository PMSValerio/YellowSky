shader_type canvas_item;

uniform float saturation : hint_range(0.0, 1.0, 0.1) = 1.0;

void fragment() {
    vec4 tex_color = texture(SCREEN_TEXTURE, SCREEN_UV);

    COLOR.rgb = mix(vec3(dot(tex_color.rgb, vec3(0.2, 0.2, 0.2))), tex_color.rgb, saturation);
	COLOR.a = tex_color.a;
}