extends Control


func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")


func _on_exit_pressed():
	get_tree().quit()


func _on_credits_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/credits.tscn")
