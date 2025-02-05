shader_type spatial;
render_mode depth_prepass_alpha, cull_disabled;


instance uniform float surface_offset : hint_range(0.0, 1.0);
uniform sampler2D surface_offset_tex : repeat_enable;
//uniform float surface_offset_weight = 1.0;
uniform float surface_scroll_speed = 1.0;
uniform sampler2D surface_color_gradient;
uniform sampler2D surface_normal : repeat_enable, hint_normal;

instance uniform float alpha_prog : hint_range(0.0, 1.0);
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform float prox_fade_dist : hint_range(0.0, 2.0);
const vec3 magic = vec3(0.06711056f, 0.00583715f, 52.9829189f);

instance uniform float emission_prog : hint_range(0.0, 1.0);
uniform vec3 emission_color : source_color;
uniform float emission_str = 1.0;

varying float surf_offset;


vec4 screen(vec4 base, vec4 blend) {
	return 1.0 - (1.0 - base) * (1.0 - blend);
}


void vertex() {
	UV.y += surface_scroll_speed * TIME;
	//vec4 offset = screen(texture(surface_offset_tex, UV), vec4(surface_offset_weight));
	vec4 offset = screen(texture(surface_offset_tex, UV), vec4(surface_offset));
	VERTEX = NORMAL * offset.r;
	surf_offset = offset.r;
}


void fragment() {
	ALBEDO = texture(surface_offset_tex, UV).r * texture(surface_color_gradient,
										vec2(surf_offset / surface_offset)).rgb;
								//vec2(surf_offset / surface_offset_weight)).rgb;
								
	float depth_tex = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	vec4 world_pos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth_tex, 1.0);
	world_pos.xyz /= world_pos.w;
	float prox_fade = ALPHA * clamp(1.0 - smoothstep(world_pos.z + prox_fade_dist, 
																world_pos.z, VERTEX.z), 0.0, 1.0);
	//float dissolve_step = smoothstep(texture(surface_offset_tex, UV*2.5).r, 0.0, COLOR.a);
	float dissolve_step = smoothstep(texture(surface_offset_tex, UV).r, 0.0, alpha_prog);
	
	ALPHA = dissolve_step * prox_fade;
	//ALPHA = prox_fade;
	
	NORMAL = texture(surface_normal, UV).rgb;
	
	//float emissive_step = smoothstep(texture(surface_offset_tex, UV).r, 1.0, 1.0-COLOR.r);
	float emissive_step = smoothstep(texture(surface_offset_tex, UV).r, 1.0, 1.0-emission_prog);
	EMISSION = emissive_step * emission_color * emission_str;
	
	//if (COLOR.a > fract(magic.z * fract(dot(FRAGCOORD.xy, magic.xy)))) {
	if (alpha_prog > fract(magic.z * fract(dot(FRAGCOORD.xy, magic.xy)))) {
		discard;
	}
}