extends AnimatableBody2D


@onready var animation_player = $AnimationPlayer
#@onready var arrow = $"../ArrowBody"
@onready var arrow_spawner = $MultiplayerSpawner

@export var player_id: int

var is_selected = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("mouse_entered",_on_mouse_entered)
	connect("mouse_exited",_on_mouse_exited)

func _on_mouse_entered() -> void:
	is_selected = true
	
func _on_mouse_exited() -> void:
	is_selected = false
	
@rpc("call_local","reliable")
func process_input() -> void:
	if not animation_player.is_playing():
			animation_player.play("new_animation")
			
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("l_click") and arrow_spawner.get_child_count() == 0 and is_selected:
			process_input.rpc()


func setup(player_data: Game.PlayerData):
	set_multiplayer_authority(player_data.id)
	name = str(player_data.id)
	Debug.dprint(player_data.name, 30)
	Debug.dprint(player_data.role, 30)

@rpc("any_peer","call_local")
func init(id:int, global_pos: Vector2):
	print(id)
	print(global_pos)
	set_multiplayer_authority(id)
	player_id = id
	global_position = global_pos
