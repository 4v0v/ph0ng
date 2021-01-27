#define MAX_LIGHTS 32

// Global lights data
struct Light {
	vec4  position;
	vec3  color;

	float ambient_intensity;
	float diffuse_intensity;
	float specular_intensity;
};
uniform int lights_count = 0;
uniform Light lights[MAX_LIGHTS];

// Camera data
struct Camera {
	mat4 projection_matrix;
	mat4 view_matrix;
	vec4 position;
};
uniform Camera camera;

// Model data
struct Model {
	mat4 matrix;
	vec4 color;
	bool is_lit;

	vec3  ambient;
	vec3  diffuse;
	vec3  specular;
	float shininess;
};
uniform Model model;

varying vec4 vertex_normal;   // vertex normal after model transformation
varying vec4 vertex_position; // vertex position after model transformation

#ifdef VERTEX
attribute vec4 initial_vertex_normal;
vec4 position(mat4 transform_projection, vec4 initial_vertex_position)
{
	vertex_normal   = normalize(model.matrix * initial_vertex_normal);
	vertex_position = normalize(model.matrix * initial_vertex_position);

	return camera.projection_matrix * camera.view_matrix * model.matrix * initial_vertex_position;
}
#endif

#ifdef PIXEL
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
	vec4 texture_color  = Texel(texture, texture_coords);

	if (!model.is_lit) return texture_color * model.color;
	
	// Phong lighting
	vec3 total_ambient,total_diffuse, total_specular;

	for (int i = 0; i < lights_count; i++) {
		Light light = lights[i];

		// Ambient
		vec3 ambient_color = vec3(light.ambient_intensity) * light.color;
		total_ambient += ambient_color;

		// Diffuse
		vec4  light_vector  = normalize(normalize(light.position) - vertex_position);
		float diffuse_dp    = max(dot(vertex_normal, light_vector), 0.0);
		vec3  diffuse_color = diffuse_dp * light.color * vec3(light.diffuse_intensity);
		total_diffuse += diffuse_color;

		// Specular
		vec4  camera_vector     = normalize(normalize(camera.position) - vertex_position);
		vec4  reflection_vertor = normalize(reflect(-light_vector, vertex_normal));
		float specular_dot      = max(dot(reflection_vertor, camera_vector), 0.0);
		float specular_exp      = pow(specular_dot, 1);
		vec3  specular_color    = specular_exp * light.color * vec3(light.specular_intensity);
		total_specular += specular_color;
	}

	vec4 phong_intensity = vec4(total_ambient + total_diffuse + total_specular, 1);

	return texture_color * (model.color + phong_intensity);
}
#endif
