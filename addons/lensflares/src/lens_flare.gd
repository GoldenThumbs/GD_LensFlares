@tool
class_name LensFlare
extends VisibleOnScreenNotifier3D

@export var flare_multimesh : MultiMesh :
	set(value):
		flare_multimesh = value
		if (is_inside_tree()):
			if (flare_multimesh && _mmesh_inst.is_valid()):
				RenderingServer.instance_set_base(_mmesh_inst, flare_multimesh.get_rid())
			_set_up_drawing()

var _vis_data := LensFlareVis.new()
var _mmesh_inst : RID

func _enter_tree() -> void:
	_vis_data.vis_data_calc(self)
	_set_up_drawing()

func _exit_tree() -> void:
	if (_mmesh_inst.is_valid()):
		RenderingServer.free_rid(_mmesh_inst)

func _process(delta: float) -> void:
	var new_vis_data := LensFlareVis.new()
	new_vis_data.vis_data_calc(self)
	
	if (new_vis_data.is_visible):
		if (!_vis_data.is_visible || _vis_data.fade_val < 1.0):
			new_vis_data.vis_mode = LensFlareVis.VisMode.FADING_IN
			if (new_vis_data.vis_mode != _vis_data.vis_mode && _mmesh_inst.is_valid()):
				RenderingServer.instance_set_visible(_mmesh_inst, true)
			new_vis_data.fade_val = move_toward(_vis_data.fade_val, 1.0, delta * 4.0)
	else:
		if (_vis_data.is_visible || _vis_data.fade_val > 0.0):
			new_vis_data.vis_mode = LensFlareVis.VisMode.FADING_OUT
			new_vis_data.fade_val = move_toward(_vis_data.fade_val, 0.0, delta * 4.0)
		elif (_mmesh_inst.is_valid()):
			RenderingServer.instance_set_visible(_mmesh_inst, false)
	if (_mmesh_inst.is_valid()):
		RenderingServer.instance_set_transform(_mmesh_inst, global_transform)
		RenderingServer.instance_geometry_set_transparency(_mmesh_inst, 1.0 - new_vis_data.fade_val)
	_vis_data = new_vis_data

func _set_up_drawing() -> void:
	if (!_mmesh_inst.is_valid()):
		_mmesh_inst = RenderingServer.instance_create()
		if (flare_multimesh):
			RenderingServer.instance_set_base(_mmesh_inst, flare_multimesh.get_rid())
		RenderingServer.instance_set_ignore_culling(_mmesh_inst, true)
		RenderingServer.instance_set_scenario(_mmesh_inst, get_world_3d().scenario)
		RenderingServer.instance_set_transform(_mmesh_inst, global_transform)

class LensFlareVis extends RefCounted:
	enum VisMode {
		NOT_VISIBLE = 0,
		IS_VISIBLE,
		FADING_IN,
		FADING_OUT
	}
	
	var is_visible := false
	var vis_mode := VisMode.NOT_VISIBLE
	var fade_val := 1.0
	
	func vis_data_calc(flare : LensFlare) -> void:
		is_visible = flare.is_on_screen()
		fade_val = float(is_visible)
		
		if (is_visible):
			vis_mode = VisMode.IS_VISIBLE
		else:
			vis_mode = VisMode.NOT_VISIBLE
