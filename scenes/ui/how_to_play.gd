extends Control

var moment: int = 0
@onready var inst1: Sprite2D = $Inst1
@onready var inst2: Sprite2D = $Inst2
@onready var inst3: Sprite2D = $Inst3
@onready var but: Button = $Next

func _on_next_pressed():
	if moment == 0:
		inst1.visible = false
		inst2.visible = true
		moment = 1
	elif moment == 1:
		inst2.visible = false
		inst3.visible = true
		but.text = "Done"
		moment = 2
	else:
		get_tree().change_scene_to_file("res://scenes/ui/title_screen.tscn")

