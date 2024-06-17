extends Node

var network = ENetMultiplayerPeer.new()
var port := 8080
var connection_ip := "127.0.0.1"

func _ready():
	connect_to_server()

func connect_to_server():
	var client_status = network.create_client(connection_ip, port)
	if client_status != OK:
		OS.alert("Failed to connect")
		return client_status
	multiplayer.multiplayer_peer = network
	multiplayer.connected_to_server.connect(_on_connected_succeed)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_connected_fail():
	print("Connection failed")

func _on_connected_succeed():
	print("Connected to server")

func _on_server_disconnected():
	print("Disconnected from server")
