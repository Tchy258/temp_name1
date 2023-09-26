extends AnimatableBody2D
@onready var animation_player = $AnimationPlayer
@export var player_id: int
@onready var body_collision = $Pivot/CollisionDetector/BodyCollision
@onready var collision_detector = $Pivot/CollisionDetector
var is_selected = false
var reached_floor = false
const GRAVITY = 200
var t = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_detector.connect("body_entered",_on_body_entered)
	connect("mouse_entered",_on_mouse_entered)
	connect("mouse_exited",_on_mouse_exited)
	sync_to_physics = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("l_click") and is_selected:
			process_input.rpc()
	if !reached_floor:
		t+=delta
		global_position.y += min(GRAVITY * t * t / 2, 5)

func _on_mouse_entered() -> void:
	is_selected = true
	
func _on_mouse_exited() -> void:
	is_selected = false


func _on_body_entered(body: Node2D) -> void:
	var floor := body as CollisionObject2D
	if floor and floor.get_collision_layer_value(0b1000):
		reached_floor = true
		$Pivot/CollisionDetector/BodyCollision.position = Vector2(1,25)
	else:
		var colliding_body := body as CharacterBody2D
		if colliding_body:
			var direction = -colliding_body.velocity.normalized()
			colliding_body.velocity=direction*300


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
	set_multiplayer_authority(id,true)
	player_id = id
	global_position = global_pos
