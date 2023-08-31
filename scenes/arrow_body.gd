extends RigidBody2D

@export var speed = 300


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	Debug.dprint(body.name)
	var colliding_body := body as CharacterBody2D
	if colliding_body:
		colliding_body.get_collision_layer_value(0b1)
		var direction = -colliding_body.velocity.normalized()
		colliding_body.velocity=direction*300
