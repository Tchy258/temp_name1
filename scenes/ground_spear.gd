extends RigidBody2D
@onready var animation_player = $Container/AnimationPlayer
@export var player_id: int
var is_selected = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("mouse_entered",_on_mouse_entered)
	connect("mouse_exited",_on_mouse_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("l_click") and is_selected:
			process_input.rpc()

func _on_mouse_entered() -> void:
	is_selected = true
	
func _on_mouse_exited() -> void:
	is_selected = false


@rpc("call_local","reliable")
func process_input() -> void:
	if not animation_player.is_playing():
			animation_player.play("activation")

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
