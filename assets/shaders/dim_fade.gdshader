shader_type canvas_item;

uniform float dim_lowlim : hint_range(0.0, 1.0, 0.01) = 0.60;
uniform float dim_highlim : hint_range(0.0, 1.0, 0.01) = 0.65;

uniform vec4 dim_colour : hint_color = vec4(0.35, 0.2, 0.25, 1.0);

uniform float alpha_lowlim : hint_range(0.0, 1.0, 0.1) = 0.675;
uniform float alpha_highlim : hint_range(0.0, 1.0, 0.1) = 0.7;

uniform bool enable = true;
uniform float height : hint_range(0.0, 1.0, 0.1) = 0.0;

void fragment() {
	vec4 colour = texture(TEXTURE, UV);
	
	float dim_mix = (height - dim_lowlim) * ((1.0) / (dim_highlim - dim_lowlim));
	dim_mix = clamp(dim_mix, 0.0, 1.0);
	colour.rgb = mix(colour.rgb, dim_colour.rgb, dim_mix);
	
	colour.a = min(colour.a, 1.0 + (height - alpha_lowlim) * ((-1.0) / (alpha_highlim - alpha_lowlim)));
	colour.a = clamp(colour.a, 0.0, 1.0);
	
	COLOR = colour;
}