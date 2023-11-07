extends RigidBody2D

@export var speed = 300
@onready var animation_player = $AnimationPlayer
@onready var collision_shape = $ArrowCollision
@onready var container = $Container
var should_move = true

signal should_be_freed
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	rotation = get_parent().get_parent().rotation
	apply_central_impulse(get_parent().get_parent().transform.y * 200)
	animation_player.connect("animation_finished",_on_animation_finished)


func _physics_process(_delta: float) -> void:
	if linear_velocity != Vector2.ZERO and should_move:
		container.global_rotation = linear_velocity.angle() - deg_to_rad(90)
	if !should_move:
		freeze = true

func _on_body_entered(body: Node2D) -> void:
	var colliding_body := body as PlayerA
	if colliding_body:
		colliding_body.receive_damage(global_position, 300, 0, 0.5)
	else:
		should_move = false
	animation_player.play("fade")
	self.collision_mask = 0b10000000

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "fade":
		emit_signal("should_be_freed")
