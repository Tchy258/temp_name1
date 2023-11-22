extends Area2D

@onready var animation_player = $"../AnimationPlayer"

func _ready():
	animation_player.play("Idle")
	# 4 = CONNECT_ONE_SHOT
	body_entered.connect(_on_body_entered, 4)
	
func _on_body_entered(_body: Node2D):
	TimerManager.on_goal_reached.rpc()
	animation_player.play("Open")
