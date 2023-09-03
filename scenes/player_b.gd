extends Node2D

@onready var spawner = $MultiplayerSpawner
@export var traps: Array[PackedScene]
@onready var ui = $Ui
var trap_buttons: Array[Button]

var trap_to_place: CompressedTexture2D
# Called when the node enters the scene tree for the first time.

enum State {
	MAP_WATCH,
	TRAP_PLACEMENT
}

var current_state: State = State.MAP_WATCH

func _ready():
	var margin_container = ui.get_children(true)[0]
	var vbox_container = margin_container.get_children(true)[0]
	for child in vbox_container.get_children(true):
		trap_buttons.append(child)
		child.connect("pressed",child._on_button_pressed)
		child.connect("emit_self",_on_button_pressed)

func _on_button_pressed(button: Button):
	if current_state == State.MAP_WATCH:
		current_state = State.TRAP_PLACEMENT
		var new_trap = button.trap
		traps.append(new_trap)
		trap_to_place = button.icon
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_state == State.TRAP_PLACEMENT:
		trap_placement()


func trap_placement():
	pass
