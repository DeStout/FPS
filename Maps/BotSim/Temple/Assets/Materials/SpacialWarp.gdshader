shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D screen_tex : hint_screen_texture;
uniform sampler2D depth_tex : hint_depth_texture;
instance uniform float scale;

bool hit_sphere(vec3 ray_origin, vec3 ray_dir, vec3 sphere_origin, float radius) {
	vec3 oc = ray_origin - sphere_origin;
	float a = dot(ray_dir, ray_dir);
	float b = 2.0 * dot(ray_dir, oc);
	float c = dot(oc, oc) - (radius * radius);
	float disc = (b * b) - 4.0 * a * c;
	return disc > 0.0;
}

vec3 get_world_position_from_uv(vec2 uv, float depth, mat4 inv_proj_m, mat4 inv_view_m) {
	vec4 ndc = vec4((uv * 2.0) - 1.0, depth, 1.0);
	vec4 view_p = inv_proj_m * ndc;
	view_p.xyz /= view_p.w;
	view_p = (inv_view_m * vec4(view_p.xyz, 1.0));
	return view_p.xyz;
}

vec2 get_uv_from_world_position(vec3 position_w, mat4 proj_m, mat4 view_m) {
	vec3 position_v = (view_m * vec4(position_w, 1.0)).xyz;
	vec4 position_cs = proj_m * vec4(position_v.xyz, 1.0);
	vec2 ndc = position_cs.xy / position_cs.w;
	return ndc.xy * 0.5 + 0.5;
}

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void fragment() {
	float depth = texture(depth_tex, SCREEN_UV).x;
	vec3 frag_p = get_world_position_from_uv(SCREEN_UV, depth, INV_PROJECTION_MATRIX, INV_VIEW_MATRIX);
	vec3 ray_dir = normalize(frag_p - CAMERA_POSITION_WORLD);

	bool hit = hit_sphere(CAMERA_POSITION_WORLD, ray_dir, NODE_POSITION_WORLD, scale * .3);

	vec4 screen_color = texture(screen_tex, SCREEN_UV);
	vec3 color;
	if (hit) {
		color = vec3(0.0);
	}
	else {
		vec2 bh_p = get_uv_from_world_position(NODE_POSITION_WORLD, PROJECTION_MATRIX, VIEW_MATRIX);
		vec2 dis_dir = normalize(bh_p - SCREEN_UV) * 0.5;
		float f =  1.0 - fresnel(0.5, NORMAL, VIEW);

		float fov = atan(-1.0 / PROJECTION_MATRIX[1][1] * 2.0);
		float dist = distance(CAMERA_POSITION_WORLD, NODE_POSITION_WORLD);
		float s = (2.0 * dist * tan(fov * 0.5)) / scale;

		vec2 uv = SCREEN_UV + (dis_dir * (f / s));
		screen_color = texture(screen_tex, uv);
		color = vec3(screen_color.r, screen_color.g, screen_color.b);

	}
	ALBEDO = color;
}