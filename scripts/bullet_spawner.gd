extends MultiplayerSpawner

@export var arrow_scene: PackedScene
@export var arrow_spawn: Node2D


func _ready() -> void:
#	set_multiplayer_authority(1)
	if not arrow_scene:
		return
	add_spawnable_scene(arrow_scene.resource_path)


func fire() -> void:
	if is_multiplayer_authority():
		fire_sever.rpc(Vector2(0,1))


@rpc("any_peer", "call_local")
func fire_sever(_target: Vector2) -> void:
	if not arrow_scene or not arrow_spawn:
		return
	var bullet = arrow_scene.instantiate()
	bullet.connect("should_be_freed",_on_free)
	bullet.global_position = arrow_spawn.global_position
	add_child(bullet, true)
			

func _on_free() -> void:
	var instance = get_child(0,true)
	call_deferred("remove_child",instance)
