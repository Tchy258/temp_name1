extends RigidBody2D

@export var speed = 300
@onready var animation_player = $AnimationPlayer
@onready var collision_shape = $ArrowCollision
signal should_be_freed
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	animation_player.connect("animation_finished",_on_animation_finished)
	


func _physics_process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	var colliding_body := body as CharacterBody2D
	if colliding_body and colliding_body.has_method("bounce"):
		colliding_body.bounce(collision_shape.global_position)
	animation_player.play("fade")
	self.collision_mask = 0b10000000

func _on_animation_finished(anim_name: String) -> void:
	emit_signal("should_be_freed")
