extends Node

const PORT = 4433

@onready var address_entry = %AddressEntry
@onready var level = %Level
@onready var startup_ui = %StartupUI

@onready var network_side_display = %NetworkSideDisplay
@onready var unique_peer_id = %UniquePeerID

func change_level(scene: PackedScene):
	for child in level.get_children():
		level.remove_child(child)
		child.queue_free()
	level.add_child(scene.instantiate())

func start_game():
	unique_peer_id.text = str(multiplayer.get_unique_id())
	startup_ui.hide()
	if multiplayer.is_server():
		change_level.call_deferred(load("res://scenes/main.tscn"))

func _on_host_mode_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server")
		return
	multiplayer.multiplayer_peer = peer
	network_side_display.text = "Host"
	start_game()

func _on_connect_client_pressed():
	var txt : String = address_entry.text
	if txt == "":
		OS.alert("Need a remote to connect to.")
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(txt, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client")
		return
	multiplayer.multiplayer_peer = peer
	network_side_display.text = "Client"
	start_game()