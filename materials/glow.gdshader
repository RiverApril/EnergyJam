shader_type spatial;

uniform vec3 albedo_color : source_color;
uniform vec3 off_color : source_color = vec3(0.16470588235294117, 0.16470588235294117, 0.16470588235294117);
uniform float pulse_speed = 1.0;
uniform float distance_power = 2; // 2=circle, bigger=more square, infinity=perfect square
uniform float inner_cut_radius = 0;
uniform float solid_radius = 0.25;
uniform float fade_raidus = 0.5;
uniform float glow_min = 0.5;
uniform float on_ness = 1.0;

varying vec3 varying_vertex;

void vertex() {
	varying_vertex = VERTEX;
}

float distance_func(float x, float y) {
	if (distance_power < 0.0) {
		return max(abs(x), abs(y));
	}
	return pow(pow(abs(x), distance_power) + pow(abs(y), distance_power), 1.0/distance_power);
}

void fragment() {
	ALBEDO = mix(off_color, albedo_color, on_ness);
	float fade = (-cos(pulse_speed*TIME)+1.0)/2.0+glow_min;
	float dist = distance_func(varying_vertex.x, varying_vertex.z);
	ALPHA = (dist < inner_cut_radius) ? 0.0
			: ((dist < solid_radius) ? 1.0
			: fade * (1.0 - dist/fade_raidus));
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
