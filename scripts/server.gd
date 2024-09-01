extends Node

signal signal_start_game(ui : Control, change_scene)

var MAIN_SCENE := preload("res://scenes/main.tscn")

var port := 8080
var connection_ip := "26.80.75.54"
var max_players := 20
var status : int

func _ready() -> void:
	signal_start_game.connect(start_game)
	# if OS.has_feature("dedicated_server"):
	# 	start_server()
	# else:
	# 	connect_to_server()


func _exit_tree() -> void:
	multiplayer.peer_connected.disconnect(_peer_connected)
	multiplayer.peer_disconnected.disconnect(_peer_disconnected)
	# multiplayer.connected_to_server.disconnect(_on_connected_succeed)
	# multiplayer.connection_failed.disconnect(_on_connected_fail)
	# multiplayer.server_disconnected.disconnect(_on_server_disconnected)


# func connect_to_server(ip_connect : String, port_connect: int) -> int:
# 	var client_peer := ENetMultiplayerPeer.new()
# 	status = client_peer.create_client(ip_connect, port_connect)
# 	if status != OK:
# 		OS.alert("CLIENT: Failed to connect")
# 		return status
# 	multiplayer.multiplayer_peer = client_peer
# 	multiplayer.connected_to_server.connect(_on_connected_succeed)
# 	multiplayer.connection_failed.connect(_on_connected_fail)
# 	multiplayer.server_disconnected.connect(_on_server_disconnected)
# 	return 0

# func _on_connected_fail() -> void:
# 	print("CLIENT: Connection failed")

# func _on_connected_succeed() -> void:
# 	print("CLIENT: Connected to server")

# func _on_server_disconnected() -> void:
# 	print("CLIENT: Disconnected from server")
	

#-------- SERVER

func start_server() -> int:
	var server_peer := ENetMultiplayerPeer.new()
	status = server_peer.create_server(port, max_players)
	if status != OK:
		OS.alert("SERVER: Failed to start multiplayer server")
		return status
	print("SERVER: Server started")
	multiplayer.multiplayer_peer = server_peer
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	return 0

func start_game(change_scene) -> void:
	# if OS.has_feature("dedicated_server"):
	start_server()
	change_scene.call_deferred(MAIN_SCENE)

func _peer_connected(peer_id : int) -> void:
	print("SERVER: Peer " + str(peer_id) + " connected")

func _peer_disconnected(peer_id : int) -> void:
	print("SERVER: Peer " + str(peer_id) + " disconnected")

# @rpc("authority", "call_remote", "reliable")
# func request_spawn_item(id: int, spawn_position: Vector3, slot_data: InSlotData) -> void:
# 	main_scene.item_spawner.spawn_inventory_item(id, spawn_position, slot_data)
