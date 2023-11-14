extends Camera2D
class_name PanningCamera2D

const MIN_ZOOM: float = 0.4
const MAX_ZOOM: float = 1.0
const ZOOM_RATE: float = 8.0
const ZOOM_INCREMENT: float = 0.1
const PAN_SPEED: float = 180

var is_cursor_inside: bool = true

var _target_zoom: float = 1.0

func _notification(what):
	match what:
		NOTIFICATION_WM_MOUSE_EXIT:
			is_cursor_inside = false
		NOTIFICATION_WM_MOUSE_ENTER:
			is_cursor_inside = true

func _ready() -> void:
	if is_multiplayer_authority():
		enabled = true
	else:
		enabled = false

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority() and is_cursor_inside:
		zoom = lerp(zoom, _target_zoom * Vector2.ONE, ZOOM_RATE * delta)
		var _mouse_pos = get_local_mouse_position()
		var viewport_rect = get_viewport_rect()
		var _viewport_start = viewport_rect.position
		var _viewport_end = viewport_rect.position + viewport_rect.size/2
		var displacement = PAN_SPEED * delta + 1/max(_target_zoom,0.000000001) * 2
		if Input.is_action_pressed("quick_pan"): displacement*=2
		if Input.is_action_pressed("move_left"):
				position.x -= displacement
		if Input.is_action_pressed("move_right"):
				position.x += displacement
		if Input.is_action_pressed("move_up"):
				position.y -= displacement
		if Input.is_action_pressed("move_down"):
				position.y += displacement


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and is_multiplayer_authority() and is_cursor_inside:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_in()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_out()


func zoom_in() -> void:
	_target_zoom = min(_target_zoom + ZOOM_INCREMENT, MAX_ZOOM)
	Game.background.scale = _target_zoom * Vector2.ONE * 1.25 * 3
	set_physics_process(true)


func zoom_out() -> void:
	_target_zoom = max(_target_zoom - ZOOM_INCREMENT, MIN_ZOOM)
	Game.background.scale = _target_zoom * Vector2.ONE * 1.25 * 3
	#Game.background.scale = max(Game.background.scale.x - ZOOM_INCREMENT , 1.25) * Vector2.ONE
	set_physics_process(true)
