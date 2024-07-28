extends MultiplayerSpawner

const STONE_SCENE = preload('res://scenes/interactable/pickup/stone_resource_rb.tscn')
const STONE_RESOURCE = preload('res://inventory/item/objects/resource_stone.tres')

@export var node_position : Node3D


func _ready() -> void:
	spawn_function = custom_spawn
	# if not multiplayer.is_server(): return
	# call_deferred('spawn_inventory_item', RandomNumberGenerator.new().randi_range(1000,9999), node_position.position, slot_data)

func custom_spawn(data) -> Node:
	var id : int = data[0]
	var pos : Vector3 = data[1]
	var slot_data_as_dict : Dictionary = data[2]
	var item_data_as_dict : Dictionary = data[3]
	var item_data_scene_path : Dictionary = data[4]

	var inventory_item : Node = load(item_data_scene_path["dropped_item"]).instantiate()

	inventory_item.synchronizer.set_multiplayer_authority(id)
	inventory_item.name = 'Item_' + str(id)
	inventory_item.position = pos
	inventory_item.network_id = id
	inventory_item.slot_data.amount_in_slot = slot_data_as_dict["amount_in_slot"]
	inventory_item.slot_data.item.quality = item_data_as_dict["quality"] 
	if inventory_item.slot_data.item is ItemDataCraftableWeapon or inventory_item.slot_data.item is ItemDataWeapon or inventory_item.slot_data.item is ItemDataCraftableTools or inventory_item.slot_data.item is ItemDataTools:
		inventory_item.slot_data.item.damage = item_data_as_dict["damage"]
	if inventory_item.slot_data.item is ItemDataWeapon or inventory_item.slot_data.item is ItemDataCraftableWeapon:
		inventory_item.slot_data.item.ammo_current = item_data_as_dict["ammo_current"]
	return inventory_item

func spawn_inventory_item(id: int, spawn_position : Vector3, slot_data_as_dict : Dictionary, item_data_as_dict : Dictionary, item_data_scene_path : Dictionary) -> void:
	if not multiplayer.is_server(): return
	spawn([id, spawn_position, slot_data_as_dict, item_data_as_dict, item_data_scene_path])
	print("SERVER: New item %s spawned at " % str(id) + str(spawn_position))

@rpc("any_peer", "call_remote", "reliable")
func request_spawn_item(id: int, spawn_position : Vector3, slot_data_as_dict : Dictionary, item_data_as_dict : Dictionary, item_data_scene_path : Dictionary) -> void:
	spawn_inventory_item(id, spawn_position, slot_data_as_dict, item_data_as_dict, item_data_scene_path)