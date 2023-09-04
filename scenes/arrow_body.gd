extends RigidBody2D

@export var speed = 300
@onready var animation_player = $AnimationPlayer
signal should_be_freed
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	animation_player.connect("animation_finished",_on_animation_finished)
	


func _physics_process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	var colliding_body := body as CharacterBody2D
	if colliding_body:
		colliding_body.get_collision_layer_value(0b1)
		var direction = -colliding_body.velocity.normalized()
		colliding_body.velocity=direction*300
	animation_player.play("fade")
	self.collision_mask = 0b10000000

func _on_animation_finished(anim_name: String) -> void:
	emit_signal("should_be_freed")
