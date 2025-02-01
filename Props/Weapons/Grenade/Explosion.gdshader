shader_type spatial;


uniform sampler2D surface_offset_tex : repeat_enable;
uniform float surface_offset_weight = 1.0;
uniform float surface_scroll_speed = 1.0;
uniform sampler2D surface_color_gradient;

uniform vec3 emission_color : source_color;
uniform float emission_strength = 1.0;


vec4 screen(vec4 base, vec4 blend) {
	return 1.0 - (1.0 - base) * (1.0 - blend);
}


void vertex() {
	UV.y += surface_scroll_speed * TIME;
	vec4 offset = screen(texture(surface_offset_tex, UV), vec4(surface_offset_weight));
	VERTEX = NORMAL * offset.r;
}


void fragment() {
	//COLOR = vec3(1.0);
	EMISSION = emission_color * emission_strength;
}