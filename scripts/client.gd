extends Node

var port := 8080
var status : int

func _exit_tree() -> void:
	multiplayer.connected_to_server.disconnect(_on_connected_succeed)
	multiplayer.connection_failed.disconnect(_on_connected_fail)
	multiplayer.server_disconnected.disconnect(_on_server_disconnected)

func connect_to_server(ip_connect : String, port_connect: int) -> int:
	var client_peer := ENetMultiplayerPeer.new()
	status = client_peer.create_client(ip_connect, port_connect)
	if status != OK:
		OS.alert("CLIENT: Failed to connect")
		return status
	multiplayer.multiplayer_peer = client_peer
	multiplayer.connected_to_server.connect(_on_connected_succeed)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	return 0

func _on_connected_fail() -> void:
	print("CLIENT: Connection failed")

func _on_connected_succeed() -> void:
	print("CLIENT: Connected to server")

func _on_server_disconnected() -> void:
	print("CLIENT: Disconnected from server")