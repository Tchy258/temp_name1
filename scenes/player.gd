class_name PlayerA
extends CharacterBody2D

var max_speed = 300
var jump_speed = 250
var acceleration = 1500
var gravity = 450
var damage: bool = false
var damage_max_time: int = 60
var damage_timer: int = damage_max_time
var blink_max_time: int = 3
var blink_timer: int = blink_max_time
@onready var player_camera = $Camera2D
@onready var player_spr = $Sprite2D

func _ready():
	if is_multiplayer_authority():
		player_camera.enabled = true
	else:
		player_camera.enabled = false

func _physics_process(delta: float) -> void:
#	Debug.dprint(velocity)
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_multiplayer_authority():
		if !damage:
			var move_input = Input.get_axis("move_left", "move_right")
			
			if Input.is_action_just_pressed("jump") and is_on_floor():
				jump.rpc()
#				jump()
			
			velocity.x = move_toward(velocity.x, max_speed * move_input, acceleration * delta)
		else:
			if is_on_floor() && damage_timer < damage_max_time - 2:
				velocity.x = 0

			if damage_timer <= 0:
				damage_timer = damage_max_time
				damage = false
				blink_timer = blink_max_time
				player_spr.visible = true
			else:
				damage_timer -= 1
				if blink_timer <= 0:
					player_spr.visible = !player_spr.visible
					blink_timer = blink_max_time
				else:
					blink_timer -= 1
				
		send_info.rpc(global_position, velocity)
#	else:
#		pass

	move_and_slide()

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("test"):
			test.rpc_id(1)

func bounce(collider_pos: Vector2) -> void:
	var direction = (global_position - collider_pos).normalized()
	self.velocity = direction*400

func receive_damage(collider_pos: Vector2, x_force: int, y_force: int) -> void:
	if !damage:
		damage = true
		var dir = sign(global_position - collider_pos)
		self.velocity = Vector2(x_force * dir.x, -y_force)
	# self.position = Vector2(self.position.x, self.position.y - 2)


@rpc("unreliable_ordered")
func send_info(pos: Vector2, vel: Vector2) -> void:
	global_position = lerp(global_position, pos, 0.5)
	velocity = lerp(velocity, vel, 0.5)


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
