extends Node2D

@export var player_a_scene: PackedScene
@export var player_b_scene: PackedScene
@onready var players: Node2D = $Players
@onready var spawn: Node2D = $Spawn

func _ready() -> void:
	Game.sort_players()
	for i in Game.players.size():
		var player_data = Game.players[i]
		var player
		if player_data.role == Game.Role.ROLE_A:
			player = player_a_scene.instantiate()
			player.global_position = spawn.get_child(i).global_position
		else:
			player = player_b_scene.instantiate()
			player.global_position = Vector2(0,0)
		player.setup(player_data)
		players.add_child(player)
		
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Label.text=str(snapped($Timer.time_left,0.01))
	
