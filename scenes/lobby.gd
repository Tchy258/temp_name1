extends MarginContainer


const MAX_PLAYERS = 4

@onready var user = %User
@onready var host = %Host
@onready var join = %Join
@onready var port = %Port

var port_number: int = Configs.port if Configs.port != 0 else int(port.value)
var username = Configs.username if Configs.username != "" else OS.get_environment("USERNAME") + (str(randi() % 1000) if Engine.is_editor_hint()
	else "")
var last_ip = Configs.last_ip if Configs.last_ip != "" else "127.0.0.1"

var selected_level = "level1.tscn"

@onready var ip = %IP
@onready var back_join: Button = %BackJoin
@onready var confirm_join: Button = %ConfirmJoin
@onready var change_port: Button = %ChangePort

@onready var role_a: Button = %RoleA
@onready var role_b: Button = %RoleB
@onready var stage_select_button = %StageSelectButton

@onready var back_ready: Button = %BackReady
@onready var ready_toggle: Button = %Ready

@onready var menus: MarginContainer = %Menus

@onready var start_menu = %StartMenu
@onready var join_menu = %JoinMenu
@onready var ready_menu = %ReadyMenu

@onready var players = %Players

@onready var start_timer: Timer = $StartTimer

@onready var time_container: HBoxContainer = %TimeContainer
@onready var time: Label = %Time


@export var lobby_player_scene: PackedScene

# { id: true }
var status = { 1 : false }

var _menu_stack: Array[Control] = []

func _ready():
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	
	Game.player_updated.connect(func(_id) : _check_ready())
	Game.players_updated.connect(_check_ready)
	
	host.pressed.connect(_on_host_pressed)
	join.pressed.connect(_on_join_pressed)
	change_port.pressed.connect(_on_change_port_pressed)
	
	confirm_join.pressed.connect(_on_confirm_join_pressed)
	
	back_join.pressed.connect(_back_menu)
	back_ready.pressed.connect(_back_menu)
	
	role_a.pressed.connect(func(): Game.set_current_player_role(Game.Role.ROLE_A))
	role_b.pressed.connect(func(): Game.set_current_player_role(Game.Role.ROLE_B))
	
	ready_toggle.pressed.connect(_on_ready_toggled)
	
	start_timer.timeout.connect(_on_start_timer_timeout)
	
	ready_toggle.disabled = true
	time_container.hide()
	#if Game.players.size() > 0:
#		for player in Game.players:
#			var lobby_player = lobby_player_scene.instantiate() as UILobbyPlayer
#			players.add_child(lobby_player)
#			lobby_player.setup(player)
#		_go_to_menu(ready_menu)
#	else:
	_go_to_menu(start_menu)
	username = Configs.username if Configs.username != "" else OS.get_environment("USERNAME") + (str(randi() % 1000) if Engine.is_editor_hint()
	else "")
	user.text = str(username)
	port_number = Configs.port if Configs.port != 0 else 5409
	port.value = port_number
	last_ip = Configs.last_ip if Configs.last_ip != "" else "127.0.0.1"
	ip.text = str(last_ip)
	#for i in range(Game.stages.size()):
	#	stage_select_button.add_item(Game.stages.keys()[i],i)
	Game.upnp_completed.connect(_on_upnp_completed)


func _process(_delta: float) -> void:
	if !start_timer.is_stopped():
		time.text = str(ceil(start_timer.time_left))
		stage_select_button.disabled = true


func _on_upnp_completed(_status) -> void:
	print(_status)
	if _status == OK:
		Debug.dprint("Port Opened", 5)
	else:
		Debug.dprint("Port Error", 5)


func _on_host_pressed() -> void:
	Configs.config_file.set_value("Network","username",user.text)
	Configs.config_file.save("user://network_settings.cfg")
	var peer = ENetMultiplayerPeer.new()
	stage_select_button.set_multiplayer_authority(multiplayer.get_unique_id())
	stage_select_button.disabled = false
	var err = peer.create_server(port_number, MAX_PLAYERS)
	if err:
		Debug.dprint("Host Error: %d" %err)
		return
	
	multiplayer.multiplayer_peer = peer
	
	var player = Game.PlayerData.new(multiplayer.get_unique_id(), user.text)
	_add_player(player)
	
	_go_to_menu(ready_menu)


func _on_join_pressed() -> void:
	Configs.config_file.set_value("Network","username",user.text)
	Configs.config_file.save("user://network_settings.cfg")
	_go_to_menu(join_menu)


func _on_confirm_join_pressed() -> void:
	Configs.config_file.set_value("Network","last_ip",ip.text)
	Configs.config_file.save("user://network_settings.cfg")
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip.text, port_number)
	stage_select_button.disabled = true
	if err:
		Debug.dprint("Host Error: %d" %err)
		return
	
	multiplayer.multiplayer_peer = peer
	
	var player = Game.PlayerData.new(multiplayer.get_unique_id(), user.text)
	_add_player(player)
	
	_go_to_menu(ready_menu)


func _on_connected_to_server() -> void:
	Debug.dprint("connected_to_server")


func _on_connection_failed() -> void:
	Debug.dprint("connection_failed")


func _on_peer_connected(id: int) -> void:
	Debug.dprint("peer_connected %d" % id)
	
	send_info.rpc_id(id, Game.get_current_player().to_dict())
	#var local_id = multiplayer.get_unique_id()
	if multiplayer.is_server():
		for player_id in status:
			set_player_ready.rpc_id(id, player_id, status[player_id])
		status[id] = false
		_set_stage.rpc(stage_select_button.text)


func _on_peer_disconnected(id: int) -> void:
	Debug.dprint("peer_disconnected %d" % id)
	_remove_player(id)
	if multiplayer.is_server():
		starting_game.rpc(false)
	
	# Server closed connection
	if id == 1:
		_back_menu()


func _on_server_disconnected() -> void:
	Debug.dprint("server_disconnected")


func _add_player(player: Game.PlayerData) -> void:
	Game.add_player(player)
	
	var lobby_player = lobby_player_scene.instantiate() as UILobbyPlayer
	players.add_child(lobby_player)
	lobby_player.setup(player)


func _remove_player(id: int):
	var lobby_player = players.find_child(str(id), true, false)
	players.remove_child(lobby_player)
	lobby_player.queue_free()
	status.erase(id)
	Game.remove_player(id)




@rpc("any_peer", "reliable")
func send_info(info_dict: Dictionary) -> void:
	var player = Game.PlayerData.new(info_dict.id, info_dict.name, info_dict.role)
	_add_player(player)


func _paint_ready(id: int) -> void:
	for child in players.get_children():
		if child.name == str(id):
			child.modulate = Color.GREEN_YELLOW


func _on_ready_toggled() -> void:
	player_ready.rpc_id(1, multiplayer.get_unique_id())


@rpc("reliable", "any_peer", "call_local")
func player_ready(id: int):
	if multiplayer.is_server():
		status[id] = !status[id]
		set_player_ready.rpc(id, status[id])
		var all_ok = true
		for ok in status.values():
			all_ok = all_ok and ok
		if all_ok and stage_select_button.text != "Choose a stage":
			starting_game.rpc(true)
		else:
			starting_game.rpc(false)


@rpc("reliable", "any_peer", "call_local")
func set_player_ready(id: int, value: bool):
	for child in players.get_children():
		var player = child as UILobbyPlayer
		if player.player_id == id:
			player.set_ready(value)


@rpc("any_peer", "call_local", "reliable")
func starting_game(value: bool):
	role_a.disabled = value
	role_b.disabled = value
	back_ready.disabled = value
	time_container.visible = value
	if value:
		start_timer.start()
	else:
		start_timer.stop()


@rpc("any_peer", "call_local", "reliable")
func start_game() -> void:
	var tree = get_tree()
	var scene_path = "res://scenes/" + selected_level
	tree.call_deferred("change_scene_to_file",scene_path)



func _check_ready() -> void:
	var roles = []
	for player in Game.players:
		if not player.role in roles and player.role != Game.Role.NONE:
			roles.push_back(player.role)
	ready_toggle.disabled = roles.size() != Game.Role.size() - 1


func _disconnect():
	multiplayer.multiplayer_peer.close()
	
	for player in players.get_children():
		players.remove_child(player)
		player.queue_free()
	
	ready_toggle.disabled = true
	status = { 1 : false }
	Game.players = []


func _on_start_timer_timeout() -> void:
	if multiplayer.is_server():
		start_game.rpc()


func _hide_menus():
	for child in menus.get_children():
		child.hide()


func _go_to_menu(menu: Control) -> void:
	_hide_menus()
	_menu_stack.push_back(menu)
	menu.show()


func _back_menu() -> void:
	_hide_menus()
	_menu_stack.pop_back()
	var menu = _menu_stack.back()
	if menu:
		menu.show()
	_disconnect()


func _back_to_first_menu() -> void:
	var first = _menu_stack.front()
	_menu_stack.clear()
	if first:
		_menu_stack.push_back(first)
		first.show()
	if Game.is_online():
		_disconnect()
	stage_select_button.disabled = false

func _on_change_port_pressed() -> void:
	Configs.config_file.set_value("Network","port",port.value)
	Configs.config_file.save("user://network_settings.cfg")
	if Game.thread.is_alive():
		Game.thread.wait_to_finish()
		Game.thread = null
	Game.thread = Thread.new()
	Game.server_port = port.value
	port_number = port.value
	Game.call_deferred("thread_func")
	Debug.dprint("Port changed to " + str(port.value) + "!",5)


func _on_stage_select_button_item_selected(option):
	if multiplayer.is_server():
		_set_stage.rpc(option)
		
		
@rpc("call_local","any_peer")
func _set_stage(option):
	stage_select_button.text = option
	if option != "Choose a stage":
		selected_level = Game.stages[option]
		if multiplayer.is_server():
			for child in players.get_children():
				var player = child as UILobbyPlayer
				if player.player_id == multiplayer.get_unique_id() and player.ready_texture.visible:
					player_ready.rpc_id(1, multiplayer.get_unique_id())


func _on_return_to_title_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/title_screen.tscn")
