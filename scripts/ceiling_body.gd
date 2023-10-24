extends AnimatableBody2D


@onready var animation_player = $AnimationPlayer
@onready var clickable_area = $ClickableArea
@onready var arrow_spawner = $MultiplayerSpawner
@onready var cooldown_timer = $Cooldown
@export var player_id: int
var is_ready = true
@export var is_auto_mode = false

var is_selected = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cooldown_timer.connect("timeout",_on_cooldown_timeout)
	clickable_area.connect("mouse_entered",_on_mouse_entered)
	clickable_area.connect("mouse_exited",_on_mouse_exited)

func _on_mouse_entered() -> void:
	is_selected = true
	
func _on_mouse_exited() -> void:
	is_selected = false
	
@rpc("any_peer","call_local","reliable")
func process_input() -> void:
	if not animation_player.is_playing():
			animation_player.play("activate")
			
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("l_click") and is_ready and is_selected and !is_auto_mode:
			cooldown_timer.start()
			is_ready = false
			process_input.rpc()
		if Input.is_action_just_pressed("automode") and is_ready and is_selected:
			cooldown_timer.start()
			is_auto_mode = !is_auto_mode
			process_input.rpc()


func setup(player_data: Game.PlayerData):
	set_multiplayer_authority(player_data.id)
	name = str(player_data.id)
	Debug.dprint(player_data.name, 30)
	Debug.dprint(player_data.role, 30)

@rpc("any_peer","call_local")
func init(id:int, global_pos: Vector2):
	set_multiplayer_authority(id)
	player_id = id
	global_position = global_pos
	
func _on_cooldown_timeout():
	is_ready = true
	if is_auto_mode:
		process_input.rpc()

