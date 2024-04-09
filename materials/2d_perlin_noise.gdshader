shader_type spatial;

uniform sampler2D base_texture;
uniform sampler2D noise_texture;

void fragment() {
    vec4 base_color = texture(base_texture, UV);
    float noise_alpha = texture(noise_texture, UV).r;
    
    // Используем noise_alpha как коэффициент затемнения для base_color
    vec3 final_color = mix(base_color.rgb, vec3(0.0), 1.0 - noise_alpha);
    
    ALBEDO = final_color;
}