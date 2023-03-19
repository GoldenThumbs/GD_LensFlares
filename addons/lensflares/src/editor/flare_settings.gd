@tool
class_name FlareSettings
extends Resource

@export var flare_tex : Texture2D :
	set(value):
		flare_tex = value
		emit_changed()
	get:
		return flare_tex
@export var flare_color : Color = Color.WHITE :
	set(value):
		flare_color = value
		emit_changed()
	get:
		return flare_color
@export var flare_spacing : float = 0.5 :
	set(value):
		flare_spacing = value
		emit_changed()
	get:
		return flare_spacing
@export var flare_segments : Array[FlareSegment] = [] :
	set(value):
		for seg in flare_segments:
			if (!seg || seg.changed.is_connected(_emit_array_element_changed)):
				continue
			seg.changed.disconnect(_emit_array_element_changed)
		flare_segments = value
		for seg in flare_segments:
			if (!seg || seg.changed.is_connected(_emit_array_element_changed)):
				continue
			seg.changed.connect(_emit_array_element_changed)
		emit_changed()
	get:
		return flare_segments

var _flare_mat := preload("res://addons/lensflares/assets/flare.material").duplicate() as ShaderMaterial

func create_flare_multimesh() -> MultiMesh:
	var m_mesh := MultiMesh.new()
	
	m_mesh.use_custom_data = true
	m_mesh.use_colors = true
	m_mesh.transform_format = MultiMesh.TRANSFORM_3D
	
	var q_mesh := QuadMesh.new()
	q_mesh.size = Vector2(0.5, 0.5)
	m_mesh.mesh = q_mesh
	m_mesh.instance_count = flare_segments.size()
	
	var tex_res := Vector2.ONE
	if (flare_tex):
		tex_res = flare_tex.get_size()
		_flare_mat.set_shader_parameter("sprite", flare_tex)
	
	_flare_mat.set_shader_parameter("modulate", flare_color)
	_flare_mat.set_shader_parameter("spacing", flare_spacing)
	
	if (m_mesh.mesh.get_surface_count() > 0):
		m_mesh.mesh.surface_set_material(0, _flare_mat)
	
	for i in m_mesh.instance_count:
		var f_seg := flare_segments[i]
		if (!f_seg):
			continue
		
		m_mesh.set_instance_custom_data(i, Color(float(f_seg.focal_fade), f_seg.offset, float(f_seg.rotate), f_seg.scale))
		
		var uv_offset := f_seg.rect.position / tex_res
		var uv_scale := f_seg.rect.size / tex_res
		m_mesh.set_instance_color(i, Color(uv_offset.x, uv_offset.y, uv_scale.x, uv_scale.y))
		
		m_mesh.set_instance_transform(i, Transform3D.IDENTITY)
	
	return m_mesh

func _emit_array_element_changed() -> void:
	emit_changed()
