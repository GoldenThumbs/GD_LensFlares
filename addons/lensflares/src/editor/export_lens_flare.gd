@tool
class_name ExportLensFlare
extends EditorInspectorPlugin

signal export_flare(multimesh)

func _can_handle(object: Object) -> bool:
	var handled := object is FlareSettings
	return handled

func _parse_begin(object: Object) -> void:
	var viewer := FlareViewer.new(object as FlareSettings)
	viewer.export_flare.connect(_emit_export_flare)
	
	add_custom_control(viewer)

func _emit_export_flare(multimesh : MultiMesh) -> void:
	export_flare.emit(multimesh)
