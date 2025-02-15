extends Node2D

@export var player_a_scene: PackedScene
@export var player_b_scene: PackedScene
@onready var players: Node2D = $Players
@onready var spawn: Node2D = $Spawn
@onready var waiting_room: Node2D = $WaitingRoom
@onready var cam_limits: Node2D = $CamLimits

@onready var lower = $CamLimits/Lower
@onready var upper = $CamLimits/Upper




@rpc("any_peer","reliable","call_local")
func _move_players():
	var children = players.get_children()
	for i in children.size():
		children[i].global_position = spawn.get_child(i).global_position
	if multiplayer.is_server():
		TimerManager.start_stage_timer.rpc(90,false)

func _ready() -> void:
	Game.sort_players()
	for i in Game.players.size():
		var player_data = Game.players[i]
		var player
		if player_data.role == Game.Role.ROLE_A:
			player = player_a_scene.instantiate()
			player.global_position = waiting_room.get_child(i).global_position
		else:
			player = player_b_scene.instantiate()
			player.global_position = Vector2(0,0)

			# Setting cam's limits
			var cam: Camera2D = player.get_node("Camera")
			if cam: 
				cam.limit_left = lower.position.x
				cam.limit_right = upper.position.x
				cam.limit_bottom = lower.position.y
				cam.limit_top = upper.position.y
				
		player.setup(player_data)
		players.call_deferred("add_child",player)
	if multiplayer.is_server():
		TimerManager.stage_timer.connect("timeout",_on_stage_timer_timeout)
		TimerManager.setup_timer.connect("timeout",_on_setup_timer_timeout)
	TimerManager.start_stage_timer.rpc(30,true)
	

func _on_stage_timer_timeout():
	TimerManager.on_stage_timer_timeout.rpc()

func _on_setup_timer_timeout():
	_move_players.rpc()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
