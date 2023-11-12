extends CharacterBody2D

@onready var area = $ClickableArea
@onready var area_shape = $ClickableArea/CollisionShape2D
@onready var animation_player = $AnimationPlayer
@onready var collision_detector = $CollisionDetector
@onready var far_end = $CollisionDetector/Square2
var is_selected = false

var speed = 0
var player_id
const GRAVITY = 400
# Called when the node enters the scene tree for the first time.
func _ready():
	collision_detector.connect("body_entered",_on_body_entered)
	area_shape.disabled = true

func _on_mouse_entered() -> void:
	is_selected = true
	
func _on_mouse_exited() -> void:
	is_selected = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("l_click") and is_selected and is_on_floor():
			process_input.rpc()
		if !is_on_floor():
			velocity.y += GRAVITY * delta
			move_and_slide()
		if is_on_floor() and area_shape.disabled:
			area.connect("mouse_entered",_on_mouse_entered)
			area.connect("mouse_exited",_on_mouse_exited)
			area_shape.disabled = false
					
					

func _on_body_entered(body: Node2D) -> void:
	var colliding_body := body as PlayerA
	if colliding_body:
		var distance_to_center = 17 if !far_end.disabled else 0
		var y_force = 200 * sign(global_position.y - distance_to_center - colliding_body.global_position.y)
		colliding_body.receive_damage(self.global_position - Vector2(0,distance_to_center),100,y_force,0.5)

@rpc("call_local","reliable")
func process_input() -> void:
	if not animation_player.is_playing():
		animation_player.play("Activate")
		animation_player.play("Keep")
	elif animation_player.current_animation == "Keep":
		animation_player.play("TurnOff")
	else:
		animation_player.play("TurnOff")

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

