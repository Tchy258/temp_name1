extends Node

signal players_updated
signal player_updated(id)

enum Role {
	NONE,
	ROLE_A,
	ROLE_B
}

# [ {id: int, name: string, rol: Rol} ]
var players: Array[PlayerData] = []

var roles := {}

const stages: Dictionary = {
	"Stage1": "level1.tscn",
	"Stage2": "level2.tscn",
	"Stage3": "level3.tscn",
}

# Emitted when UPnP port mapping setup is completed (regardless of success or failure).
signal upnp_completed(error)

# Replace this with your own server port number between 1024 and 65535.
var server_port = Configs.port if Configs.port != 0 else 5409
var thread = null
var background

func add_player(player: PlayerData) -> void:
	players.append(player)
	players_updated.emit()


func remove_player(id: int) -> void:
	for i in players.size():
		if players[i].id == id:
			players.remove_at(i)
			break
	players_updated.emit()


func get_player(id: int) -> PlayerData:
	for player in players:
		if player.id == id:
			return player
	return null


func get_current_player() -> PlayerData:
	return get_player(multiplayer.get_unique_id())


@rpc("any_peer", "reliable", "call_local")
func set_player_role(id: int, role: Role) -> void:
	var player = get_player(id)
	player.role = role
	player_updated.emit(id)


func set_current_player_role(role: Role) -> void:
	set_player_role.rpc(multiplayer.get_unique_id(), role)


func is_online() -> bool:
	return not multiplayer.multiplayer_peer is OfflineMultiplayerPeer and \
		multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED


func sort_players() -> void:
	players.sort_custom(func (a, b): return a.id < b.id)

func _upnp_setup(_server_port):
	# UPNP queries take some time.
	var upnp = UPNP.new()
	var err = upnp.discover()
	
	print("discover")
	
	if err != OK:
		push_error(str(err))
		call_deferred("emit_signal","upnp_completed", err)
		return

	var gateway = upnp.get_gateway()
	if gateway and gateway.is_valid_gateway():
		upnp.add_port_mapping(_server_port, _server_port, ProjectSettings.get_setting("application/config/name"), "UDP")
		upnp.add_port_mapping(_server_port, _server_port, ProjectSettings.get_setting("application/config/name"), "TCP")
		print("signal2")
		
		call_deferred("emit_signal","upnp_completed", OK)

func _ready():
	#self.process_thread_group = Node.PROCESS_THREAD_GROUP_SUB_THREAD
	server_port = Configs.port if Configs.port != 0 else 5409
	thread = Thread.new()
	call_deferred("thread_func")

func thread_func():
	thread.start(_upnp_setup.bind(server_port))
	print("start")

func _exit_tree():
	# Wait for thread finish here to handle game exit while the thread is running.
	thread.wait_to_finish()
	

class PlayerData:
	var id: int
	var name: String
	var role: Role
	
	func _init(new_id: int, new_name: String, new_role: Role = Role.NONE) -> void:
		id = new_id
		name = new_name
		role = new_role
	
	func to_dict() -> Dictionary:
		return {
			"id": id,
			"name": name,
			"role": role
		}
