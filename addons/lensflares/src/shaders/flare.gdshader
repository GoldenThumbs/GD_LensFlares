shader_type spatial;
render_mode cull_back, depth_test_disabled, depth_draw_never, blend_mix, unshaded, skip_vertex_transform;

uniform sampler2D sprite : source_color;
uniform float spacing = 0.5;

varying float fade_val;

void vertex()
{
	vec4 ss_pos = (PROJECTION_MATRIX * VIEW_MATRIX) * vec4(NODE_POSITION_WORLD, 1.0);
	if (ss_pos.w > 0.0)
		ss_pos.xy /= ss_pos.w;
	ss_pos.z = 0.0;
	
	fade_val = length(ss_pos.xy);
	
	float angle = atan(-ss_pos.y, -ss_pos.x);
	vec2 dir = vec2(cos(angle), sin(angle));
	mat2 rot = mat2(
		vec2(dir.x,-dir.y),
		vec2(dir.y, dir.x));
	
	VERTEX.xy = rot * VERTEX.xy;
	VERTEX.y = -VERTEX.y;
	VERTEX.x *= VIEWPORT_SIZE.y / VIEWPORT_SIZE.x;
	VERTEX.xyz = ss_pos.xyz + VERTEX;
	VERTEX.xy = VERTEX.xy + ((float(INSTANCE_ID) + INSTANCE_CUSTOM.g) * spacing) * -ss_pos.xy;
	POSITION = vec4(VERTEX, 1.0);
	
	UV *= COLOR.ba;
	UV += COLOR.rg;
}

void fragment()
{
	vec4 color = texture(sprite, UV);
	ALBEDO = color.rgb;
	ALPHA = color.a * fade_val;
}
