@tool
extends EditorPlugin

var _exporter := ExportLensFlare.new()
var _export_menu := EditorFileDialog.new()

var _flare_mmesh : MultiMesh

func _enter_tree() -> void:
	_exporter.export_flare.connect(_export_flare)
	
	_export_menu.name = "LensFlareExportMenu"
	_export_menu.title = "Export Lens Flare"
	_export_menu.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	_export_menu.size = Vector2i(720, 512)
	_export_menu.add_filter("*.multimesh", "Save as a MultiMesh resource.")
	_export_menu.file_selected.connect(_save_flare)
	_export_menu.hide()
	
	add_inspector_plugin(_exporter)
	get_editor_interface().get_editor_main_screen().add_child(_export_menu)

func _exit_tree() -> void:
	remove_inspector_plugin(_exporter)
	if (_export_menu):
		_export_menu.queue_free()

func _export_flare(flare : MultiMesh) -> void:
	_flare_mmesh = flare
	_export_menu.show()

func _save_flare(path : String) -> void:
	if (_flare_mmesh):
		var err := ResourceSaver.save(_flare_mmesh, path)
		_flare_mmesh.take_over_path(path)
		var f_sys := get_editor_interface().get_resource_filesystem()
		f_sys.update_file(path)
		
		if (err != OK):
			push_error("Failed to save Flare MultiMesh with error [%s]" % error_string(err))
	_flare_mmesh = null
	_export_menu.hide()
