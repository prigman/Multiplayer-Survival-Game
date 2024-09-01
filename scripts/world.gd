class_name World extends Node

const PLAYER_SCENE := preload("res://scenes/player.tscn")
const TREE_SCENE := preload("res://scenes/pine_tree.tscn")
const ROCK_1_SCENE := preload("res://scenes/stone_1.tscn")
const ROCK_2_SCENE := preload("res://scenes/stone_2.tscn")
const ROCK_3_SCENE := preload("res://scenes/stone_3.tscn")
const WORLD_CRATE_SCENE := preload("res://scenes/interactable/world_pine-wood-crate_staticbody.tscn")

@export var multiplayer_spawner : MultiplayerSpawner
@export var item_spawner : MultiplayerSpawner
@export var world_resources_spawner : MultiplayerSpawner
@export var world_crate_spawner : MultiplayerSpawner
@export var object_creator : Node3D
@export var nav_mesh : MNavigationRegion3D

@onready var players_spawn_node := %Players
# @onready var inventory_interface := %InventoryInterface
# @onready var reticle := %Reticle
# @onready var craft_menu := %CraftMenu
# @onready var debug_ui := %Debug
# @onready var crosshair := %Crosshair
# @onready var weapon_hud := %WeaponHud

# @onready var player_stats := %PlayerStats

# @onready var death_ui := %DeathUI
# @onready var quick_slot_ui := %PlayerQuickSlot

func _ready() -> void:
	multiplayer_spawner.spawn_function = custom_spawn
	# world_resources_spawner.spawn_function = world_resources_custom_spawn
	# world_crate_spawner.spawn_function = world_crate_custom_spawn
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(delete_player)

func add_player(id: int) -> void:
	if not multiplayer.is_server(): return
	
	var spawn_position := Vector3.ZERO
	multiplayer_spawner.spawn([id, spawn_position])
	print("Player %d spawned at " % [id] + str(spawn_position))

func delete_player(id: int) -> void:
	if not multiplayer.is_server(): return
	print("SERVER: delete_player function called")
	players_spawn_node.get_node(str(id)).queue_free()

func custom_spawn(data : Array) -> CharacterBody3D:
	var id : int = data[0]
	var pos : Vector3 = data[1]

	var player: Player = PLAYER_SCENE.instantiate()
	# player.set_multiplayer_authority(id)

	player.peer_id = id
	player.name = str(id)
	player.position = pos
	return player

func add_world_resource(object : Array) -> void:
	world_resources_spawner.spawn([object[1], object[2], object[0]])


func world_resources_custom_spawn(data : Array) -> StaticBody3D:
	var pos : Vector3 = data[0]
	var rot : Vector3 = data[1]
	var type_of_resource : int = data[2]
	var resource: StaticBody3D
	var scene : PackedScene
	match type_of_resource:
		0:
			scene = TREE_SCENE
		1:
			scene = ROCK_1_SCENE
		2:
			scene = ROCK_2_SCENE
		3:
			scene = ROCK_3_SCENE

	resource = scene.instantiate()

	resource.position = pos
	resource.rotation = rot
	return resource

func add_world_crate(crate_position : Vector3, crate_rotation : Vector3) -> void:
	world_crate_spawner.spawn([crate_position, crate_rotation])

func world_crate_custom_spawn(data : Array) -> StaticBody3D:
	var pos : Vector3 = data[0]
	var rot : Vector3 = data[1]
	var world_crate : StaticBody3D = WORLD_CRATE_SCENE.instantiate()
	world_crate.position = pos
	world_crate.rotation = rot
	return world_crate