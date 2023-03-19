extends Node3D

@export var travel_speed := 3.0
@export var travel_dist := 6.0
@export var travel_axis := Vector3(1, 0, 0)
var _side := true

func _physics_process(delta: float) -> void:
	translate(travel_axis * (delta * travel_speed) * (2.0 * float(_side) - 1.0))
	if (_side):
		_side = position.dot(travel_axis) < travel_dist
	else:
		_side = -position.dot(travel_axis) > travel_dist
