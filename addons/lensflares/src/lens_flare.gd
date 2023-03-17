@tool
class_name LensFlare
extends MultiMeshInstance3D

@export var flare_spacing : float = 0.5
@export var flare_settings : FlareSettings :
	set (value):
		flare_settings = value
		if (flare_settings):
			multimesh = _create_flare_multimesh()
		else:
			multimesh = null
	get:
		return flare_settings

var _flare_mat := preload("res://addons/lensflares/assets/flare.material").duplicate() as ShaderMaterial

func _create_flare_multimesh() -> MultiMesh:
	var m_mesh := MultiMesh.new()
	
	m_mesh.use_custom_data = true
	m_mesh.use_colors = true
	m_mesh.transform_format = MultiMesh.TRANSFORM_3D
	
	if (!flare_settings || !flare_settings.flare_mesh):
		return m_mesh
	
	m_mesh.mesh = flare_settings.flare_mesh
	m_mesh.instance_count = flare_settings.flare_segments.size()
	
	var tex_res := Vector2.ONE
	if (flare_settings.flare_tex):
		tex_res = flare_settings.flare_tex.get_size()
		_flare_mat.set_shader_parameter("sprite", flare_settings.flare_tex)
	
	_flare_mat.set_shader_parameter("spacing", flare_spacing)
	
	for i in m_mesh.instance_count:
		var f_seg := flare_settings.flare_segments[i]
		
		m_mesh.set_instance_custom_data(i, Color(float(f_seg.focal_fade), f_seg.offset, float(f_seg.rotate)))
		
		var uv_offset := f_seg.rect.position / tex_res
		var uv_scale := f_seg.rect.size / tex_res
		m_mesh.set_instance_color(i, Color(uv_offset.x, uv_offset.y, uv_scale.x, uv_scale.y))
		
		m_mesh.set_instance_transform(i, Transform3D.IDENTITY.scaled(Vector3(f_seg.scale, f_seg.scale, f_seg.scale)))
		
	
	if (m_mesh.mesh.get_surface_count() > 0):
		m_mesh.mesh.surface_set_material(0, _flare_mat)
	
	return m_mesh

func _ready() -> void:
	if (flare_settings):
			multimesh = _create_flare_multimesh()
