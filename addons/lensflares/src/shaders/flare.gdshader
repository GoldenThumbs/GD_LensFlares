shader_type spatial;
render_mode cull_disabled, depth_test_disabled, depth_draw_never, blend_mix, unshaded, skip_vertex_transform;

uniform sampler2D sprite : source_color;
uniform float spacing = 0.5;

varying float fade_val;

void vertex()
{
	vec4 v_pos = VIEW_MATRIX * vec4(NODE_POSITION_WORLD, 1.0);
	vec4 ss_pos = PROJECTION_MATRIX * v_pos;
	ss_pos.z = 0.0;
	if (ss_pos.w > 0.0)
		ss_pos.xy /= ss_pos.w;
	
	if (int(INSTANCE_CUSTOM.b) == 1)
	{
		float angle = atan(-v_pos.y, -v_pos.x);
		vec2 dir = vec2(cos(angle), sin(angle));
		VERTEX.xy = vec2(
			dir.x*VERTEX.x + dir.y*VERTEX.y,
			dir.x*VERTEX.y - dir.y*VERTEX.x );
	}
	
	vec4 ss_vrt = PROJECTION_MATRIX * vec4(VERTEX, 1.0);
	if (ss_vrt.w > 0.0)
		ss_vrt.xy /= ss_vrt.w;
	
	ss_vrt.y *= -1.0;
	
	fade_val = 1.0;
	if (int(INSTANCE_CUSTOM.r) == 1)
		fade_val *= min(length(ss_pos.xy) * 0.5, 1.0);
	
	ss_vrt.xy *= INSTANCE_CUSTOM.a;
	
	VERTEX.xy = ss_vrt.xy + ss_pos.xy + (float(INSTANCE_ID) + INSTANCE_CUSTOM.g) * spacing * -ss_pos.xy;
	
	POSITION = vec4(VERTEX.xyz, 1.0);
	
	UV *= COLOR.ba;
	UV += COLOR.rg;
}

void fragment()
{
	vec4 color = texture(sprite, UV);
	ALBEDO = color.rgb;
	ALPHA *= color.a * fade_val;
}
