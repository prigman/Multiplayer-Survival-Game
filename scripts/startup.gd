extends Node

@onready var address_entry := %AddressEntry
@onready var level := %Level
@onready var startup_ui := %StartupUI

func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		Server.signal_start_game.emit(change_level)

func change_level(scene: PackedScene) -> void:
	for child in level.get_children():
		level.remove_child(child)
		child.queue_free()
	level.add_child(scene.instantiate())

func _on_connect_client_pressed() -> void:
	Server.connect_to_server(address_entry.text, Server.port)
	startup_ui.hide()
