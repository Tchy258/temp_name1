class_name PlayerA
extends CharacterBody2D

var max_speed = 200
var jump_speed = 200
var acceleration = 1000
var gravity = 400
@onready var player_camera = $Camera2D

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
		var move_input = Input.get_axis("move_left", "move_right")
		
		if Input.is_action_just_pressed("jump") and is_on_floor():
			jump.rpc()
#			jump()
	
		velocity.x = move_toward(velocity.x, max_speed * move_input, acceleration * delta)
		
		send_info.rpc(global_position, velocity)
#	else:
#		pass

	move_and_slide()

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("test"):
			test.rpc_id(1)

func bounce(collider_pos: Vector2, reverse: bool = false) -> void:
	var direction = (global_position - collider_pos).normalized()
	if reverse: direction *= -1
	print(direction)
	self.velocity = direction*300
	print("bounce")

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
