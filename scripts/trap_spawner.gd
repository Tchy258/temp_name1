extends MultiplayerSpawner

@onready var trap_spawn = $"../DraggableTrap"
@onready var container = $"../TrapContainer"

func place(trap_id: TrapManager.traps, trap_position: Vector2, trap_rotation) -> void:
	#place_server.rpc(scene)
	var scene = TrapManager.get_trap_scene(trap_id)
	var trap = scene.instantiate()
	trap.player_id = get_parent().this_player_data.id
	print(trap.player_id)
	trap.global_position = trap_position
	trap.rotation = trap_rotation
	container.add_child(trap, true)
	trap.init.rpc(trap.player_id,trap_position)


@rpc("any_peer", "call_remote")
func place_server(trap_id:TrapManager.traps) -> void:
	var scene = TrapManager.get_trap_scene(trap_id)
	var trap = scene.instantiate()
	add_child(trap, true)
	trap.global_position = trap_spawn.global_position
	
