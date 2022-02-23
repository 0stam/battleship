shader_type canvas_item;

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	float fraction = abs(sin(length(UV) * 1.0 + TIME));
	color.r = color.r * fraction;
	color.g = color.g * fraction;
	color.b = color.b * fraction;
	COLOR = color;
}
