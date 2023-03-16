@tool
class_name LensFlareCapture
extends Node

@export var material : CanvasItemMaterial
@export var max_distance : float = 50.0

var _flare_canvas : RID
var _flare_item : RID
var _parent_cam : Camera3D

var _flares : Array[LensFlare] = []
var _flare_vis := {}

func add_flare(flare : LensFlare) -> void:
	_flares.push_back(flare)
	_flare_vis[flare] = _vis_data_calc(flare)

func remove_flare(flare : LensFlare) -> void:
	_flares.erase(flare)
	_flare_vis.erase(flare)

func _draw_flares(delta : float) -> void:
	RenderingServer.canvas_item_clear(_flare_item)
	var center := get_viewport().get_visible_rect().size * 0.5
	for flare in _flares:
		var pos := _parent_cam.unproject_position(flare.global_position)
		var to_center := center - pos
		var angle := to_center.angle()
		
		var data := FlareData.new(pos, flare)
		var vis_data_old := _flare_vis[flare] as FlareVis
		var vis_data_new := _vis_data_calc(flare)
		
		if (vis_data_new.behind):
			_flare_vis[flare] = vis_data_new
			return
		
		if (vis_data_new.visible):
			if (!vis_data_old.visible || vis_data_old.fade_val < 1.0):
				vis_data_new.flare_mode = FlareVis.FlareMode.FADING_IN
				vis_data_new.fade_val = move_toward(vis_data_old.fade_val, 1.0, delta * 4.0)
		else:
			if (vis_data_old.visible || vis_data_old.fade_val > 0.0):
				vis_data_new.flare_mode = FlareVis.FlareMode.FADING_OUT
				vis_data_new.fade_val = move_toward(vis_data_old.fade_val, 0.0, delta * 4.0)
		
		if (flare.flare_distance_scale):
			data.flare_scale /= vis_data_new.dist
		
		if (vis_data_new.flare_mode != FlareVis.FlareMode.NOT_VIEWABLE):
			var focal_mod := minf((to_center / center).length(), 1.0)
			_draw_common(data, to_center, angle, vis_data_new.fade_val, focal_mod)
		
		_flare_vis[flare] = vis_data_new

func _draw_common(data : FlareData, to_center : Vector2, angle : float, alpha_mod : float, focal_mod : float) -> void:
	var spacing := 0.0
	for segment in data.flare_props.segments:
		var seg_scale := data.flare_scale * segment.scale
		var rect_src := segment.rect
		var rect_dst := Rect2(rect_src.size * -0.5 * seg_scale, rect_src.size * seg_scale)
		var coord := data.screen_pos + (spacing + segment.offset) * to_center
		var rot := angle * int(segment.rotate)
		
		var alpha := segment.modulate.a * alpha_mod
		alpha *= focal_mod if (segment.focal_fade) else 1.0
		var col := Color(segment.modulate, alpha)
		
		RenderingServer.canvas_item_add_set_transform(_flare_item, Transform2D(rot, coord))
		RenderingServer.canvas_item_add_texture_rect_region(_flare_item, rect_dst, data.flare_props.atlas_tex.get_rid(), rect_src, col)
		
		spacing += data.flare_spacing

func _is_ray_occlusion(pos : Vector3, world_state : PhysicsDirectSpaceState3D) -> bool:
	var ray_query := PhysicsRayQueryParameters3D.create(_parent_cam.global_position, pos)
	return !world_state.intersect_ray(ray_query).is_empty()

func _vis_data_calc(flare : LensFlare) -> FlareVis:
	var vis_data := FlareVis.new()
	
	vis_data.dist = flare.global_position.distance_to(_parent_cam.global_position)
	
	var world_state := _parent_cam.get_world_3d().direct_space_state
	
	var visible := _parent_cam.is_position_in_frustum(flare.global_position)
	var in_range := vis_data.dist <= max_distance
	
	vis_data.visible = visible && in_range
	if (vis_data.visible):
		var occluded := _is_ray_occlusion(flare.global_position, world_state)
		vis_data.visible = vis_data.visible && !occluded
	vis_data.behind = _parent_cam.is_position_behind(flare.global_position)
	
	if (vis_data.visible):
		vis_data.flare_mode = FlareVis.FlareMode.VIEWABLE
		vis_data.fade_val = 1.0
	else:
		vis_data.flare_mode = FlareVis.FlareMode.NOT_VIEWABLE
		vis_data.fade_val = 0.0
	
	return vis_data

func _enter_tree() -> void:
	if (get_parent() is Camera3D):
		_parent_cam = get_parent()
		
		if (!Engine.is_editor_hint()):
			_flare_canvas = RenderingServer.canvas_create()
			RenderingServer.viewport_attach_canvas(get_viewport().get_viewport_rid(), _flare_canvas)
			
			_flare_item = RenderingServer.canvas_item_create()
			RenderingServer.canvas_item_set_parent(_flare_item, _flare_canvas)
			if (material):
				RenderingServer.canvas_item_set_material(_flare_item, material.get_rid())
	
	add_to_group("flare_capture", true)
	update_configuration_warnings()

func _exit_tree() -> void:
	_parent_cam = null
	
	if (_flare_item.is_valid()):
		RenderingServer.canvas_item_clear(_flare_item)
		RenderingServer.free_rid(_flare_item)
		
	if (_flare_canvas.is_valid()):
		RenderingServer.free_rid(_flare_canvas)
	
	remove_from_group("flare_capture")

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if (!_parent_cam):
		warnings.push_back("Parent is not of type \"Camera\"!")
	
	return warnings

func _process(delta: float) -> void:
	if (_parent_cam && _parent_cam.current && !Engine.is_editor_hint()):
		_draw_flares(delta)

class FlareVis extends RefCounted:
	enum FlareMode {
		NOT_VIEWABLE = 0,
		VIEWABLE,
		FADING_IN,
		FADING_OUT
	}
	
	var visible := false
	var behind := false
	var flare_mode := FlareMode.NOT_VIEWABLE
	var fade_val := 1.0
	var dist := 0.0

class FlareData extends Object:
	var screen_pos : Vector2
	var flare_props : FlareProperties
	var flare_scale : float
	var flare_spacing : float
	
	func _init(n_screen_pos : Vector2, flare : LensFlare) -> void:
		screen_pos = n_screen_pos
		flare_props = flare.flare_properties
		flare_scale = flare.flare_scale
		flare_spacing = flare.flare_spacing
