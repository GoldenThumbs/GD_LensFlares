shader_type spatial;
render_mode cull_back, depth_test_disabled, depth_draw_never, blend_mix, unshaded, skip_vertex_transform;

uniform sampler2D sprite : hint_default_white;
uniform float spacing = 0.5;

void vertex()
{
	vec4 ss_pos = (PROJECTION_MATRIX * VIEW_MATRIX) * vec4(NODE_POSITION_WORLD, 1.0);
	if (ss_pos.w > 0.0)
		ss_pos.xy /= ss_pos.w;
	ss_pos.z = 0.0;
	VERTEX.y = -VERTEX.y;
	VERTEX.x *= VIEWPORT_SIZE.y / VIEWPORT_SIZE.x;
	VERTEX.xyz = ss_pos.xyz + VERTEX;
	VERTEX.xy = VERTEX.xy + (float(INSTANCE_ID) * spacing) * -ss_pos.xy;
	POSITION = vec4(VERTEX, 1.0);
	
}

void fragment()
{
	ALBEDO = texture(sprite, UV).rgb;
}
