class_name PlayerA
extends CharacterBody2D

var max_speed = 300
var jump_speed = 250
var acceleration = 1500
var gravity = 450
var damage: bool = false
var in_wind:bool=false
var wind_velocity:Vector2 = Vector2.ZERO
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
	if not is_on_floor():
		velocity.y += gravity * delta
		animation.travel("jump")
	if in_wind:
		velocity.y += wind_velocity.y*delta
	if is_multiplayer_authority():
		if !damage:
			var move_input = Input.get_axis("move_left", "move_right")
			if is_on_floor():
				if is_zero_approx(move_input):
					animation.travel("idle")
				elif move_input>0.5:
					animation.travel("walk")
				elif move_input < -0.5:
					animation.travel("walk")
			if move_input>0.5:
				pivot.scale.x=1
			if move_input < -0.5:
				pivot.scale.x=-1
				
				
			if Input.is_action_just_pressed("jump") and is_on_floor():
				jump.rpc()
				animation.travel("jump")
#				jump()
			
			velocity.x = move_toward(velocity.x, (max_speed * move_input) + wind_velocity.x, acceleration * delta)
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
