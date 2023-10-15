extends CharacterBody2D

@onready var timer = $Timer

var active: bool = false
var exploding: bool = false

const GRAVITY = 400

@onready var mine_spr : Sprite2D = $Sprite
@onready var explosion_rad : Area2D = $ExplosionRadius
@onready var animation : AnimationPlayer = $Animation
@onready var explosion_spr = $Explosion
var players: Array[PlayerA]
var player_id
# Called when the node enters the scene tree for the first time.
func _ready():
	timer.connect("timeout",_on_timer_timeout)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):

	if !is_on_floor():
		velocity.y += GRAVITY * delta
		move_and_slide()	
	if active && !exploding:
		animation.speed_scale+= 2 * delta

	

func _on_area_2d_body_entered(body:Node2D):
	var character := body as CharacterBody2D
	if character and !active:
		animation.play("Beeping")
		active = true
		timer.start(2.6)

func _on_explosion_radius_body_entered(body:Node2D):
	var character := body as CharacterBody2D
	if character and character not in players:
		players.push_back(character)

func _on_explosion_radius_body_exited(body:Node2D):
	var character := body as CharacterBody2D
	if character and character in players:
		players.pop_at(players.find(character))


func explosion_damage():
	for player in players:
		player.receive_damage(self.global_position, 100, 200)

func _on_timer_timeout():
	exploding = true
	animation.speed_scale = 1
	animation.play("Explosion")

func setup(player_data: Game.PlayerData):
	set_multiplayer_authority(player_data.id)
	name = str(player_data.id)
	Debug.dprint(player_data.name, 30)
	Debug.dprint(player_data.role, 30)

func mine_queue_free():
	if is_multiplayer_authority():
		queue_free()

@rpc("any_peer","call_local")
func init(id:int, global_pos: Vector2):
	set_multiplayer_authority(id,true)
	mine_spr.z_index = 1 if is_multiplayer_authority() else -1
	player_id = id
	global_position = global_pos
