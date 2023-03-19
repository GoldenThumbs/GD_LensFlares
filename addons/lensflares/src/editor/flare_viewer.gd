@tool
class_name FlareViewer
extends VBoxContainer

signal export_flare(multimesh)

var _export := Button.new()
var _mmesh := MultiMeshInstance3D.new()

var _flare_ref : FlareSettings

func _init(flare : FlareSettings) -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	_export.text = "Export as MultiMesh"
	_export.pressed.connect(_on_export_pressed)
	
	_mmesh.translate(Vector3(-1.0, 0.5, 0.0))
	
	_flare_ref = flare
	_flare_ref.changed.connect(_update_on_change)
	
	var viewport_ui := SubViewportContainer.new()
	viewport_ui.stretch = true
	viewport_ui.custom_minimum_size = Vector2(256.0, 256.0)
	
	var sub_viewport := SubViewport.new()
	var world := World3D.new()
	var env := Environment.new()
	world.environment = env
	sub_viewport.world_3d = world
	sub_viewport.transparent_bg = false
	
	_update_on_change()
	
	var cam := Camera3D.new()
	cam.translate(Vector3(0.0, 0.0, 2.0))
	
	sub_viewport.add_child(_mmesh)
	sub_viewport.add_child(cam)
	viewport_ui.add_child(sub_viewport)
	
	add_child(viewport_ui)
	add_child(_export)

func _enter_tree() -> void:
	pass

func _exit_tree() -> void:
	if (_flare_ref && _flare_ref.changed.is_connected(_update_on_change)):
		_flare_ref.changed.disconnect(_update_on_change)

func _on_export_pressed() -> void:
	if (_flare_ref):
		export_flare.emit(_flare_ref.create_flare_multimesh())

func _update_on_change() -> void:
	if (_flare_ref):
		_mmesh.multimesh = _flare_ref.create_flare_multimesh()
