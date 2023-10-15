extends Node

var config_file = ConfigFile.new()

@onready var err = config_file.load("user://network_settings.cfg")
var port: int = 5409
var username: String = OS.get_environment("USERNAME") + (str(randi() % 1000) if Engine.is_editor_hint() else "")
var last_ip: String = "127.0.0.1"

signal config_loaded
# If the file didn't load, ignore it.
func _ready():
	if err != OK:
		return
	else:
		port = int(config_file.get_value("Network", "port",5409))
		username = config_file.get_value("Network", "username", OS.get_environment("USERNAME") + (str(randi() % 1000) if Engine.is_editor_hint()
		else ""))
		last_ip = config_file.get_value("Network","last_ip","127.0.0.1")
	emit_signal("config_loaded")
