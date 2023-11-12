extends Area2D

var enabled = true
var lifted = false
var can_be_rotated = false
@onready var sprite = $Sprite2D

signal placed
signal canceled

func _ready():
	visible = false

func _unhandled_input(event):
	if enabled and is_multiplayer_authority():
		if lifted and event is InputEventMouseMotion:
			position = get_global_mouse_position()
		if event is InputEventMouseButton and event.is_action("l_click"):
			_deactivate_placer(placed,global_position)
		elif event is InputEventMouseButton and event.is_action("r_click"):
			_deactivate_placer(canceled,null)
		if can_be_rotated:
			if event.is_action_pressed("counter_clockwise_rotation"):
				sprite.rotation= fmod(sprite.rotation + deg_to_rad(45), 2 * PI)
			elif event.is_action_pressed("clockwise_rotation"):
				sprite.rotation= fmod(sprite.rotation - deg_to_rad(45), 2 * PI)

func _deactivate_placer(sig: Signal, pos):
	lifted = false
	if pos:
		sig.emit(pos,sprite.rotation)
	else:
		sig.emit()
	enabled = false
	visible = false
