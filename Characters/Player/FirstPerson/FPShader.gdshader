shader_type spatial;
render_mode unshaded, depth_draw_never;

uniform float depth_factor: hint_range(0.0, 256.0, 0.1) = 80.0;

uniform sampler2D DEPTH_TEXTURE: hint_depth_texture;


void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}


void fragment() {
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	float linear_depth = 1.0 / (depth * INV_PROJECTION_MATRIX[2].w + INV_PROJECTION_MATRIX[3].w);

	ALBEDO = vec3(linear_depth / depth_factor);
}