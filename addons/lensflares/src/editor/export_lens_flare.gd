@tool
class_name ExportLensFlare
extends EditorInspectorPlugin

signal export_flare(flare_settings)

var _flare_settings : FlareSettings

func _can_handle(object: Object) -> bool:
	return object is FlareSettings

func _parse_begin(object: Object) -> void:
	var export_btn := Button.new()
	export_btn.text = "Export as MultiMesh"
	export_btn.connect("pressed", Callable(self, "_on_export_btn_pressed"))
	add_custom_control(export_btn)
	
	_flare_settings = object as FlareSettings

func _on_export_btn_pressed() -> void:
	emit_signal("export_flare", _flare_settings)
