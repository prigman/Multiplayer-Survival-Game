shader_type spatial;



uniform sampler2D mterrain_heightmap:filter_nearest;
uniform sampler2D mterrain_normals:filter_nearest;

uniform sampler2D grass_texture:filter_linear;

uniform vec3 grass_color : source_color;
uniform sampler2D noise_texture : filter_linear_mipmap;
uniform float specular_value : hint_range(0.0, 1.0);

uniform vec3 region_world_position;
uniform float region_size;
uniform float region_a;
uniform float region_b;
uniform int min_lod;
varying vec3 world_pos;
varying vec2 region_uv;

void vertex(){
	world_pos = (NODE_POSITION_WORLD + VERTEX);
	region_uv = (world_pos.xz - region_world_position.xz)/region_size;
	region_uv = region_uv*region_a + region_b;
	VERTEX.y = texture(mterrain_heightmap, region_uv).r;
	world_pos.y = VERTEX.y;
	vec3 n = texture(mterrain_normals, region_uv).rgb;
	n.rb=fma(n.rb,vec2(2.0),vec2(-1.0));
	NORMAL = n;
	//Scale world uv for terrain texture
	world_pos /= 10.0;
}

void fragment(){
	BACKLIGHT = vec3(0.8,0.8,0.8);
	METALLIC = 0.0;
  	ROUGHNESS = 1.0;
	SPECULAR = specular_value;
	float noise = texture(noise_texture, world_pos.xz*0.4).r;
	ALBEDO = vec3(noise) * grass_color;
	//ALBEDO = color_value * texture(grass_texture, world_pos.xz).rgb;
	//ALBEDO = vec3(region_uv, 0.0);
}
