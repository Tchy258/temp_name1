extends Camera2D

const MAX_CAMERA_DISTANCE := 50.0
const MAX_CAMERA_PERCENT := 0.1
const CAMERA_SPEED := 0.1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var viewport : Viewport = get_viewport()
	var viewport_center = viewport.get_size() / 2.0
	var direction = viewport.get_mouse_position() - viewport_center
	var percent = (direction / viewport.size * 2.0).length()
	var camera_position: Vector2
	if percent < MAX_CAMERA_PERCENT:
		camera_position = global_position + direction.normalized() * MAX_CAMERA_DISTANCE * (percent / MAX_CAMERA_PERCENT)
	else:
		camera_position = global_position + direction.normalized() * MAX_CAMERA_DISTANCE

	global_position = lerp(global_position, camera_position, CAMERA_SPEED)
