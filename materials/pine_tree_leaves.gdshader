shader_type spatial;
render_mode cull_disabled;

uniform sampler2D leave_texture : filter_linear_mipmap;

const mat4 dither = mat4(
	vec4(0.0625, 0.5625, 0.1875,  0.6875),
	vec4(0.8125, 0.3125, 0.9375,  0.4375),
	vec4(0.25, 0.75, 0.125, 0.625),
	vec4(1.0, 0.5, 0.875,  0.375));

float getValue(int x, int y) {
	return dither[x][y];
}
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float limit = getValue(int(FRAGCOORD.x) % 4, int(FRAGCOORD.y) % 4);
	if (COLOR.a < limit - 0.001) {
		discard;
	}
	ALPHA_SCISSOR_THRESHOLD = 0.8;
	ALPHA = texture(leave_texture, UV).a;
	ALBEDO = texture(leave_texture, UV).rgb;
}


//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
