extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(_body: Node2D):
	TimerManager.on_goal_reached.rpc()
