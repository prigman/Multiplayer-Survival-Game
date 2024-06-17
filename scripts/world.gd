class_name World extends Node

const PLAYER_SCENE = preload("res://scenes/player.tscn")

@export var enemy1: CharacterBody3D
@export var enemy2: CharacterBody3D
@export var enemy3: CharacterBody3D

@onready var players = %Players

func _enter_tree():
	var spawner := $MultiplayerSpawner
	spawner.spawn_function = _spawn_player

func _ready():
	multiplayer.peer_connected.connect(add_player_character)
	multiplayer.peer_disconnected.connect(delete_player_character)
	Global.global_world = self

func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player_character)
	multiplayer.peer_disconnected.disconnect(delete_player_character)

func _spawn_player(id: int):
	var player := PLAYER_SCENE.instantiate()

	player.set_multiplayer_authority(id)

	player.peer_id = id
	player.name = str(id)
	return player


func add_player_character(id: int):
	$MultiplayerSpawner.spawn(id)

func exit_game(id: int):
	delete_player_character(id)

func delete_player_character(id: int):
	rpc("RPC_delete_player", id)

@rpc("any_peer", "call_local")
func RPC_delete_player(id: int):
	players.get_node(str(id)).queue_free()

func _on_enemy_spawn_timer_timeout():
	if !enemy1.visible:
		enemy1.show()
	if !enemy2.visible:
		enemy2.show()
	if !enemy3.visible:
		enemy3.show()
