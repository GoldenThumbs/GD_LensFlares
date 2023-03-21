@tool
class_name FlareSegment
extends Resource

@export var rect : Rect2 = Rect2(0, 0, 32, 32) :
	set(value):
		rect = value
		emit_changed()
	get:
		return rect
@export var focal_fade : bool = true :
	set(value):
		focal_fade = value
		emit_changed()
	get:
		return focal_fade
@export var focal_scale : bool = true :
	set(value):
		focal_scale = value
		emit_changed()
	get:
		return focal_scale
@export var scale : Vector2 = Vector2.ONE :
	set(value):
		scale = value
		emit_changed()
	get:
		return scale
@export var offset : float = 0.0 :
	set(value):
		offset = value
		emit_changed()
	get:
		return offset
@export var rotate : bool = false :
	set(value):
		rotate = value
		emit_changed()
	get:
		return rotate
