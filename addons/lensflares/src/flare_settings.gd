@tool
class_name FlareSettings
extends Resource

@export var flare_tex : Texture2D
@export var flare_mesh : Mesh = preload("res://addons/lensflares/assets/quad.tres").duplicate()
@export var flare_segments : Array[FlareSegment] = []
