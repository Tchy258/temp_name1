extends Node

@onready var stage_timer = Timer.new()
@onready var setup_timer = Timer.new()
@onready var timer_display = CanvasLayer.new()
@onready var container = VBoxContainer.new()
@onready var timer_label = Label.new()


func _ready():
	timer_display.visible = false
	timer_label.set("theme_override_constants/outline_size", 2)
	timer_label.set("theme_override_colors/font_outline_color", Color.BLACK)
	timer_label.set("theme_override_font_sizes/font_size", 18)
	add_child(timer_display)
	container.set_anchors_preset(Control.PRESET_CENTER_TOP)
	timer_display.layer = 99
	timer_display.add_child(stage_timer)
	timer_display.add_child(setup_timer)
	container.add_child(timer_label)
	timer_display.add_child(container)

func _process(_delta):
	if !stage_timer.is_stopped():
		var time_minutes = int(stage_timer.time_left / 60) % 60
		var time_seconds = fmod(stage_timer.time_left, 60.0)
		timer_label.text = "%02d:%02d" % [time_minutes, time_seconds]
	elif !setup_timer.is_stopped():
		var time_minutes = int(setup_timer.time_left / 60) % 60
		var time_seconds = fmod(setup_timer.time_left, 60.0)
		timer_label.text = "%02d:%02d" % [time_minutes, time_seconds]
		
		
@rpc("any_peer","call_local","reliable")
func start_stage_timer(time: int, is_setup: bool):
	timer_display.visible = true
	if is_setup:
		setup_timer.start(time)
	else:
		setup_timer.stop()
		stage_timer.start(time)

@rpc("any_peer","call_local","reliable")
func on_stage_timer_timeout():
	stage_timer.stop()
	timer_label.text = "Player B wins!"
	await get_tree().create_timer(5).timeout
	timer_display.visible = false
	Game.players.clear()
	Game.roles.clear()
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")

@rpc("any_peer","call_local","reliable")
func on_goal_reached():
	stage_timer.stop()
	if timer_label.text != "Player B wins!":
		timer_label.text = "Player A wins!"
		await get_tree().create_timer(5).timeout
		timer_display.visible = false
		Game.players.clear()
		Game.roles.clear()
		multiplayer.multiplayer_peer = null
		get_tree().change_scene_to_file("res://scenes/lobby.tscn")
