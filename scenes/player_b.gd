class_name PlayerB
extends Node2D

@onready var spawner = $MultiplayerSpawner
@export var current_trap: TrapManager.traps
@onready var camera = $Camera
@onready var trap_placer = $DraggableTrap
var current_button: Button
var base_placer_position: Vector2
var trap_to_place: CompressedTexture2D
var this_player_data: Game.PlayerData
var trap_props: Dictionary
# Called when the node enters the scene tree for the first time.

enum State {
	MAP_WATCH,
	TRAP_CLICK,
	TRAP_PLACEMENT
}

var current_state: State = State.MAP_WATCH

func _ready():
	if is_multiplayer_authority():
		var canvas_layer = camera.get_children(true)[0]
		var ui = canvas_layer.get_children(true)[0]
		var margin_container = ui.get_children(true)[0]
		var vbox_container = margin_container.get_children(true)[0]
		
		for child in vbox_container.get_children(true):
			child.connect("pressed",child._on_button_pressed)
			child.connect("emit_self",_on_button_pressed)
		

func _on_button_pressed(button: Button):
	if is_multiplayer_authority():
		_on_trap_canceled()
		if current_state == State.MAP_WATCH:
			current_state = State.TRAP_CLICK
			current_trap = button.trap
			trap_to_place = button.icon
			trap_props = button.trap_props
			base_placer_position = get_local_mouse_position()
			current_button = button
			trap_placer.connect("placed", _on_trap_placed,CONNECT_ONE_SHOT)
			trap_placer.connect("canceled",_on_trap_canceled,CONNECT_ONE_SHOT)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if is_multiplayer_authority():
		if current_state == State.TRAP_CLICK:
			trap_click()

func trap_click():
	trap_placer.sprite.texture = trap_to_place
	trap_placer.enabled = true
	trap_placer.scale = trap_props.scale
	if trap_props.get("can_be_rotated"):
		trap_placer.can_be_rotated = true
	trap_placer.visible = true
	trap_placer.lifted = true
	trap_placer.position = base_placer_position
	current_state = State.TRAP_PLACEMENT
	

func _reset_placer():
	if !current_button: return
	current_button.disabled = false
	current_state = State.MAP_WATCH
	trap_placer.sprite.rotation = 0
	trap_placer.can_be_rotated = false


func _on_trap_placed(trap_position: Vector2, trap_rotation):
	if !is_multiplayer_authority(): return
	spawner.place(current_trap,trap_position, trap_rotation)
	trap_placer.disconnect("canceled",_on_trap_canceled)
	_reset_placer()
	
func _on_trap_canceled():
	if !is_multiplayer_authority(): return
	trap_placer.disconnect("placed",_on_trap_placed)
	_reset_placer()

func setup(player_data: Game.PlayerData):
	this_player_data = player_data
	set_multiplayer_authority(player_data.id,true)
	name = str(player_data.id)
	Debug.dprint(player_data.name, 30)
	Debug.dprint(player_data.role, 30)
	
