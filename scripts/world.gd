class_name World extends Node

const PLAYER_SCENE = preload("res://scenes/player.tscn")

@export var enemy1: CharacterBody3D
@export var enemy2: CharacterBody3D
@export var enemy3: CharacterBody3D
@export var multiplayer_spawner : MultiplayerSpawner
@export var item_spawner : MultiplayerSpawner

@onready var players_spawn_node := %Players

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	multiplayer_spawner.spawn_function = custom_spawn
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(delete_player)
	Server.main_scene = get_node(get_path())

func _on_enemy_spawn_timer_timeout() -> void:
	if !enemy1.visible:
		enemy1.show()
	if !enemy2.visible:
		enemy2.show()
	if !enemy3.visible:
		enemy3.show()

func add_player(id: int) -> void:
	if not multiplayer.is_server(): return
	
	var spawn_position = Vector3.ZERO
	multiplayer_spawner.spawn([id, spawn_position])
	print("Player %d spawned at " % [id] + str(spawn_position))

func delete_player(id: int) -> void:
	if not multiplayer.is_server(): return
	print("SERVER: delete_player function called")
	players_spawn_node.get_node('Player_' + str(id)).queue_free()

@rpc("any_peer","reliable","call_local")
func delete_player_rpc(id:int)->void:
	if not multiplayer.is_server(): return
	delete_player(id)

func custom_spawn(data) -> Node:
	var id = data[0]
	var pos = data[1]

	var player: Player = PLAYER_SCENE.instantiate()
	player.set_multiplayer_authority(id)
	player.peer_id = id
	player.name = 'Player_' + str(id)
	player.position = pos
	return player
