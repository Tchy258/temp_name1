extends RigidBody2D
@onready var animation_player = $Container/AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	_activate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass



func _activate() -> void:
	animation_player.play("activation")
