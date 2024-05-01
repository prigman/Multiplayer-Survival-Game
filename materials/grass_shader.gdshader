shader_type spatial;

render_mode cull_disabled, vertex_lighting;

group_uniforms properties;
uniform float specular : hint_range(0.0, 1.0);
uniform float roughness : hint_range(0.0, 1.0);
uniform float metallic : hint_range(0.0, 1.0);
uniform vec2 fadeout_envelope;

group_uniforms color;
uniform vec3 top_color : source_color;
uniform vec3 bottom_color : source_color;
uniform vec3 noise_color : source_color;

group_uniforms maps;
uniform sampler2D foliage_texture : filter_linear_mipmap;
uniform sampler2D heightmap_normals : hint_normal;
uniform float heightmap_scale;
uniform sampler2D color_noise;
uniform float color_noise_scale;
uniform float color_noise_intensity : hint_range(0.0, 1.0);

group_uniforms wind;
uniform bool wind;
uniform sampler2D wind_noise;
uniform float wind_scale = 1.0;
uniform float wind_intensity = 1.0;
uniform float wind_speed = 1.0;
uniform float wind_darken : hint_range(0.0, 1.0);

varying vec2 heightmap_position;
varying vec3 vert_normal;

const mat4 dither = mat4(
	vec4(0.0625, 0.5625, 0.1875,  0.6875),
	vec4(0.8125, 0.3125, 0.9375,  0.4375),
	vec4(0.25, 0.75, 0.125, 0.625),
	vec4(1.0, 0.5, 0.875,  0.375));

vec3 unpack_normal(vec4 rgba) {
	vec3 n = rgba.xzy * 2.0 - vec3(1.0);
	n.z *= -1.0;
	return n;
}

float getValue(int x, int y) {
	return dither[x][y];
}

float remap(float value, float istart, float istop, float ostart, float ostop) {
    return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
}

void fragment() {
	NORMAL = (VIEW_MATRIX * (MODEL_MATRIX * vec4(vert_normal, 0.0))).xyz;
	
	float limit = getValue(int(FRAGCOORD.x) % 4, int(FRAGCOORD.y) % 4);
	
	ALPHA = texture(foliage_texture, UV).a;
	if (COLOR.a < limit - 0.001) {
		discard;
	}
	ALPHA_SCISSOR_THRESHOLD = 0.7;
	
	float color_noise_at_position = mix(0, texture(color_noise, heightmap_position * color_noise_scale).r, color_noise_intensity);
	
	vec3 base_color = mix(top_color, bottom_color, UV.y);
	vec3 mixed_color = mix(base_color, noise_color, color_noise_at_position);
	
	float wind_darkening = mix(1.0, texture(wind_noise, heightmap_position * wind_scale + vec2(TIME * wind_speed)).r, wind_darken);
	if (!wind) { wind_darkening = 1.0; }
	ALBEDO = mixed_color * texture(foliage_texture, UV).rgb * wind_darkening;
//	ALBEDO = vec3(COLOR.a);
	SPECULAR = specular;
	ROUGHNESS = roughness;
	METALLIC = metallic;
}

void vertex() {
	float heightmap_size = float(textureSize(heightmap_normals, 0).x);
	heightmap_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz * (1.0 / (heightmap_scale * heightmap_size)) + vec2(0.5);
	
	if (wind) {
		float wind_intensity_at_position = texture(wind_noise, heightmap_position * wind_scale + vec2(TIME * wind_speed)).r * wind_intensity;
		float wind_offset = mix(wind_intensity_at_position, 0.0, UV.y);
		wind_offset *= sin(TIME * wind_speed); // Добавляем анимацию синусоидального движения
		VERTEX.x += wind_offset;
	}
	
	vec3 world_position = (MODEL_MATRIX * vec4(VERTEX, 1)).xyz;
	float camera_distance = distance(world_position, INV_VIEW_MATRIX[3].xyz);
	float fadeout = clamp(remap(camera_distance, fadeout_envelope.x, fadeout_envelope.y, 1, 0), 0, 1);
	//COLOR.a = fadeout;
	
	vert_normal = unpack_normal(texture(heightmap_normals, heightmap_position));
	NORMAL = vert_normal;
}