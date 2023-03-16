@tool
class_name LensFlare
extends Node3D

@export var flare_properties : FlareProperties
@export var flare_spacing : float = 0.2
@export var flare_scale : float = 1.0
@export var flare_distance_scale := false

var _flare_capture : LensFlareCapture

func _enter_tree() -> void:
	_flare_capture = get_tree().get_first_node_in_group("flare_capture") as LensFlareCapture

func _exit_tree() -> void:
	_flare_capture = null

func _ready() -> void:
	if (_flare_capture && visible):
		_flare_capture.add_flare(self)

func show() -> void:
	super()
	if (_flare_capture):
		_flare_capture.add_flare(self)

func hide() -> void:
	super()
	if (_flare_capture):
		_flare_capture.remove_flare(self)
