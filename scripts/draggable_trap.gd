extends Area2D

var enabled = true
var lifted = false
@onready var sprite = $Sprite2D
signal placed
signal canceled

func _ready():
	visible = false

func _unhandled_input(event):
	if enabled:
		if lifted and event is InputEventMouseMotion:
			position = get_global_mouse_position()
		if event is InputEventMouseButton and event.is_action("l_click"):
			_deactivate_placer(placed,global_position)
		elif event is InputEventMouseButton and event.is_action("r_click"):
			_deactivate_placer(canceled,null)

func _deactivate_placer(sig: Signal, pos):
	lifted = false
	if pos:
		sig.emit(pos)
	else:
		sig.emit()
	enabled = false
	visible = false
