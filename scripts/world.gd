class_name World extends Node

const PLAYER_SCENE = preload("res://scenes/player.tscn")

@export var enemy1: CharacterBody3D
@export var enemy2: CharacterBody3D
@export var enemy3: CharacterBody3D
@export var spawn_point : Vector3
@export var multiplayer_spawner : MultiplayerSpawner

@onready var players_spawn_node = %Players

func _ready():
	Global.global_world = self
	multiplayer_spawner.spawn_function = custom_spawn
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(delete_player)

func _on_enemy_spawn_timer_timeout():
	if !enemy1.visible:
		enemy1.show()
	if !enemy2.visible:
		enemy2.show()
	if !enemy3.visible:
		enemy3.show()


# func add_player(id: int):
# 	print("SERVER: add_player function called")
# 	var player := PLAYER_SCENE.instantiate()
# 	player.peer_id = id
# 	player.name = str(id)
# 	player.set_multiplayer_authority(id)
# 	players_spawn_node.add_child(player, true)
# 	print("SERVER: player ", player.name, " with authority ", player.get_multiplayer_authority())
func add_player(id: int):
	if not multiplayer.is_server(): return
	
	var spawn_position = Vector3.ZERO
	multiplayer_spawner.spawn([id, spawn_position])
	print("Player %d spawned at " % [id] + str(spawn_position))

# func delete_player(id: int):
# 	print("SERVER: delete_player function called")
# 	if not has_node(str(id)):
# 		return
# 	get_node(str(id)).queue_free()

func delete_player(id: int):
	if not multiplayer.is_server(): return
	get_node(multiplayer_spawner.spawn_path).get_node(str(id)).queue_free()

func custom_spawn(vars) -> Node:
	var id = vars[0]
	var pos = vars[1]

	var p: Player = PLAYER_SCENE.instantiate()
	p.set_multiplayer_authority(id)
	p.name = str(id)
	p.position = pos
	return p


func _on_connect_client_pressed():
	pass # Replace with function body.
