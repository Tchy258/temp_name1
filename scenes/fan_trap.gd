extends CharacterBody2D

@onready var area_shape = $ClickableArea/CollisionShape2D
@onready var area = $ClickableArea
@onready var animation_player = $AnimationPlayer
@onready var animation_tree = $AnimationTree
@onready var wind_box = $WindBox
@onready var wind_area = $WindBox/CollisionShape2D
@onready var animation= $AnimationTree.get("parameters/playback")


var is_selected = false

var speed = 0
var player_id
const GRAVITY = 9
var in_wind=[]

# Called when the node enters the scene tree for the first time.
func _ready():
	wind_box.connect("body_entered",_on_body_entered)
	wind_box.connect("body_exited", _on_body_exited)
	area.connect("mouse_entered",_on_mouse_entered)
	area.connect("mouse_exited",_on_mouse_exited)


func _on_mouse_entered() -> void:
	is_selected = true
	
func _on_mouse_exited() -> void:
	is_selected = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("l_click") and is_selected:
			process_input.rpc()

func _on_body_entered(body: Node2D) -> void:
	var colliding_body := body as PlayerA
	if colliding_body:
		colliding_body.set_wind.rpc(-transform.y*1000, true)


func _on_body_exited(body:Node2D)-> void:
	var colliding_body := body as PlayerA
	if colliding_body:
		colliding_body.set_wind.rpc(Vector2.ZERO, false)

@rpc("call_local","reliable")
func process_input() -> void:
	if animation_tree.animation_finished:
		animation.travel("On")
		await get_tree().create_timer(10).timeout
		animation.travel("Off")
		

func setup(player_data: Game.PlayerData):
	set_multiplayer_authority(player_data.id)
	name = str(player_data.id)
	Debug.dprint(player_data.name, 30)
	Debug.dprint(player_data.role, 30)

@rpc("any_peer","call_local")
func init(id:int, global_pos: Vector2):
	set_multiplayer_authority(id,true)
	player_id = id
	global_position = global_pos

