extends Area2D

var enabled = true
var lifted = false
@onready var sprite = $Sprite2D
signal placed

func _ready():
	visible = false

func _unhandled_input(event):
	if enabled:
		if lifted and event is InputEventMouseMotion:
			position = get_global_mouse_position()
		if event is InputEventMouseButton and event.is_action("l_click"):
			lifted = false
			placed.emit(global_position)
			enabled = false
			visible = false
