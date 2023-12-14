class_name PlayerA
extends CharacterBody2D

const NORMAL_GRAVITY = 1100
const WIND_GRAVITY = 500

var max_speed = 180
var jump_speed = 400
var acceleration = 3300
var gravity = NORMAL_GRAVITY
var damage: bool = false
var in_wind:bool=false
var wind_velocity:Vector2 = Vector2.ZERO
var jump_buffer : int = 0
var coyote_time : int = 10
var jumping : bool = false
var falling: bool = false
var move_dir: int = 0
var move_changed: bool = false
@onready var player_camera = $Camera2D
@onready var pivot = $Pivot
@onready var player_spr = $Pivot/Sprite2D
@onready var damage_timer = $DamageTimer
@onready var animation= $AnimationTree.get("parameters/playback")
@onready var animation_player = $AnimationPlayer

func _ready():
	if is_multiplayer_authority():
		player_camera.enabled = true
	else:
		player_camera.enabled = false
	

func _physics_process(delta: float) -> void:
#	Debug.dprint(velocity)
	if jump_buffer > 0:
		jump_buffer -= 1
	if coyote_time > 0:
		coyote_time -= 1
	if not is_on_floor():
		velocity.y += gravity * delta
		animation.travel("jump")
		if !falling and !jumping:
			if coyote_time == 0:
				coyote_time = 8
				falling = true
				
		if Input.is_action_just_pressed("jump"):
			if !jumping and (coyote_time > 0):
				jump.rpc()
				animation.travel("jump")
				jump_buffer = 0
				jumping = true
				coyote_time = 0
			else:
				jump_buffer = 8
	if in_wind:
		gravity = WIND_GRAVITY
		velocity.y += wind_velocity.y*delta
	else:
		gravity = NORMAL_GRAVITY
	if is_multiplayer_authority():
		if !damage:
			var move_input = Input.get_axis("move_left", "move_right")
			if (Input.get_action_strength("move_left") == 0) or (Input.get_action_strength("move_right") == 0):
				move_dir = move_input
				move_changed = false
			elif move_dir != 0:
				if !move_changed:
					move_dir *= -1
					move_changed = true
			if is_on_floor():
				if is_zero_approx(move_dir):
					animation.travel("idle")
				elif move_dir>0.5:
					animation.travel("walk")
				elif move_dir < -0.5:
					animation.travel("walk")
				jumping = false
				falling = false
				coyote_time = 0
			if move_dir>0.5:
				pivot.scale.x=1
			if move_dir < -0.5:
				pivot.scale.x=-1
				
				
			if (Input.is_action_just_pressed("jump") or jump_buffer > 0) and is_on_floor():
				jump.rpc()
				animation.travel("jump")
				jump_buffer = 0
				jumping = true
#				jump()
			wind_velocity.x = wind_velocity.x * 0.9 if is_on_floor() and in_wind else wind_velocity.x
			velocity.x = move_toward(velocity.x, (max_speed * move_dir) + wind_velocity.x, acceleration * delta)
		else:
			if is_on_floor():
				velocity.x *= 0.8
		var current_animation = animation.get_current_node()
		send_info.rpc(global_position, velocity, current_animation)
	if damage:
		player_spr.visible = !player_spr.visible

	move_and_slide()

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("test"):
			test.rpc_id(1)

func bounce(collider_pos: Vector2) -> void:
	var direction = (global_position - collider_pos).normalized()
	self.velocity = direction*400

func receive_damage(collider_pos: Vector2, x_force: int, y_force: int, hitstun: float = 1.0) -> void:
	if !damage:
		damage = true
		damage_timer.start(hitstun)
		var dir = sign(global_position - collider_pos)
		self.velocity = Vector2(x_force * dir.x, -y_force)
	# self.position = Vector2(self.position.x, self.position.y - 2)


@rpc("unreliable_ordered","authority")
func send_info(pos: Vector2, vel: Vector2,anim: String) -> void:
	global_position = lerp(global_position, pos, 0.5)
	velocity = lerp(velocity, vel, 0.5)
	if animation.get_current_node() != anim:
		animation.travel(anim)

@rpc("call_local", "reliable")
func jump():
	velocity.y = -jump_speed



func setup(player_data: Game.PlayerData):
	set_multiplayer_authority(player_data.id)
	name = str(player_data.id)
	Debug.dprint(player_data.name, 30)
	Debug.dprint(player_data.role, 30)
	

@rpc
func test():
#	if is_multiplayer_authority():
	Debug.dprint("test - player: %s" % name, 30)


func _on_damage_timer_timeout():
	damage = false
	player_spr.visible = true

@rpc("call_local","reliable","any_peer")
func set_wind(vel, status):
	in_wind = status
	wind_velocity = vel
	

