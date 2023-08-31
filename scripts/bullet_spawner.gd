extends MultiplayerSpawner

@export var arrow_scene: PackedScene
@export var arrow_spawn: Node2D


func _ready() -> void:
#	set_multiplayer_authority(1)
	if not arrow_scene:
		return
	add_spawnable_scene(arrow_scene.resource_path)


func fire() -> void:
	fire_sever.rpc(Vector2(0,1))


@rpc("any_peer", "call_local")
func fire_sever(target: Vector2) -> void:
	if not arrow_scene or not arrow_spawn:
		return
	if get_child_count(true) == 0:
		var bullet = arrow_scene.instantiate()
		add_child(bullet, true)
		bullet.connect("body_entered",_on_bullet_body_entered)
		bullet.global_position = arrow_spawn.global_position
			

func _on_bullet_body_entered(_body: Node2D) -> void:
	var instance = get_child(0,true)
	call_deferred("remove_child",instance)
