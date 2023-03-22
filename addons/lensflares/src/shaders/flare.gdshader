shader_type spatial;
render_mode depth_test_disabled, depth_draw_never, blend_add, unshaded, skip_vertex_transform;

uniform vec4 modulate : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D sprite : source_color, hint_default_white;
uniform float spacing = 0.5;
instance uniform vec4 light_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
instance uniform vec2 proximity_fade = vec2(1.0, 2.0);

varying float fade_val;

void vertex()
{
	vec4 v_pos = VIEW_MATRIX * vec4(NODE_POSITION_WORLD, 1.0);
	vec4 ss_pos = PROJECTION_MATRIX * v_pos;
	if (ss_pos.w > 0.0)
		ss_pos.xy /= ss_pos.w;
	
	vec2 ss_offset = ss_pos.xy + INSTANCE_CUSTOM.g * spacing * -ss_pos.xy;
	
	int booleans = int(INSTANCE_CUSTOM.r);
	bool b_fade = bool(booleans & (1 << 0));
	bool b_rot = bool(booleans & (1 << 1));
	bool b_scale = bool(booleans & (1 << 2));
	
	VERTEX.xy *= INSTANCE_CUSTOM.ba;
	
	float node_dist = length(ss_pos.xy);
	
	vec2 dir = vec2(0.0, 0.0);
	if (b_rot || b_scale)
	{
		float angle = atan(-v_pos.y, -v_pos.x);
		dir = vec2(cos(angle), sin(angle));
	}
	
	if (b_rot)
	{
		VERTEX.xy = vec2(
			dir.x*VERTEX.x - dir.y*VERTEX.y,
			dir.x*VERTEX.y + dir.y*VERTEX.x );
	}
	
	if (b_scale)
	{
		float k = (1.0 - min(node_dist * 0.5, 1.0));
		
		mat2 mat = mat2(
			vec2(1.0 + (k-1.0) * dir.x*dir.x, (k-1.0) * dir.y*dir.x),
			vec2((k-1.0) * dir.x*dir.y, 1.0 + (k-1.0) * dir.y*dir.y) );
		
		VERTEX.xy = mat * VERTEX.xy;
	}
	
	vec4 ss_vrt = PROJECTION_MATRIX * vec4(VERTEX, 1.0);
	if (ss_vrt.w > 0.0)
		ss_vrt.xy /= ss_vrt.w;
	
	fade_val = clamp((-v_pos.z - proximity_fade.x) * proximity_fade.y, 0.0, 1.0);
	if (b_fade)
		fade_val *= min(node_dist * 0.5, 1.0);
	
	VERTEX.xy = ss_vrt.xy + ss_offset;
	
	POSITION = vec4(VERTEX.xyz, 1.0);
	
	UV *= COLOR.ba;
	UV += COLOR.rg;
}

void fragment()
{
	vec4 color = texture(sprite, UV) * modulate * light_color;
	ALBEDO = color.rgb;
	ALPHA *= color.a * fade_val;
}
