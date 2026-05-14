shader_type spatial;
uniform vec3 albedo : source_color;
uniform float metallic : hint_range(0.0,1.0)= 0;
uniform float roughness : hint_range(0.0,1.0)= 0.02;
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
vec3 normal = texture(texture_normal, UV).rgb;
ALBEDO = albedo;
METALLIC = metallic;
ROUGHNESS = roughness;	
NORMAL_MAP = normal;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
