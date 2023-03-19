extends Camera3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var e := event as InputEventMouseMotion
		var pitch := -e.relative.y * 0.2
		var yaw := -e.relative.x * 0.2
		
		rotate_y(deg_to_rad(yaw))
		rotate_object_local(Vector3(1, 0, 0), deg_to_rad(pitch))

func _physics_process(_delta: float) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	position += self.transform.basis * Vector3(dir.x, 0.0, dir.y) * 0.25
