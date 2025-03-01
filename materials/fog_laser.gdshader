shader_type spatial;
render_mode blend_add;

uniform sampler3D noise_texture : source_color;
uniform vec3 albedo_color : source_color;
uniform vec3 wind = vec3(0.1, 0.2, 0.3);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float noise = texture(noise_texture, vec3(SCREEN_UV, 0.0) + wind * TIME).r;
	ALBEDO = albedo_color;
	ALPHA = noise;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
