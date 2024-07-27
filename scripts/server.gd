extends Node

var port := 8080
var connection_ip := "127.0.0.1"
var max_players := 20
var main_scene : Node3D
var status

func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		start_server()
	else:
		connect_to_server()


func _exit_tree() -> void:
	multiplayer.peer_connected.disconnect(_peer_connected)
	multiplayer.peer_disconnected.disconnect(_peer_disconnected)
	multiplayer.connected_to_server.disconnect(_on_connected_succeed)
	multiplayer.connection_failed.disconnect(_on_connected_fail)
	multiplayer.server_disconnected.disconnect(_on_server_disconnected)

	
func connect_to_server():
	var client_peer = ENetMultiplayerPeer.new()
	status = client_peer.create_client(connection_ip, port)
	if status != OK:
		OS.alert("CLIENT: Failed to connect")
		return status
	multiplayer.multiplayer_peer = client_peer
	multiplayer.connected_to_server.connect(_on_connected_succeed)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_connected_fail() -> void:
	print("CLIENT: Connection failed")

func _on_connected_succeed() -> void:
	print("CLIENT: Connected to server")

func _on_server_disconnected() -> void:
	print("CLIENT: Disconnected from server")
	

#-------- SERVER

func start_server():
	var server_peer = ENetMultiplayerPeer.new()
	status = server_peer.create_server(port, max_players)
	if status != OK:
		OS.alert("SERVER: Failed to start multiplayer server")
		return status
	print("SERVER: Server started")
	multiplayer.multiplayer_peer = server_peer
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	
func _peer_connected(peer_id) -> void:
	print("SERVER: Peer " + str(peer_id) + " connected")

func _peer_disconnected(peer_id) -> void:
	print("SERVER: Peer " + str(peer_id) + " disconnected")