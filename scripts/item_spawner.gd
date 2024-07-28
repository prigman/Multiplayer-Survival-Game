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
	var slot_data: InSlotData = SerializationUtils.deserialize_in_slot_data(data[2])
	var inventory_item : Node = load(slot_data.item.dictionary["dropped_item"]).instantiate()
	inventory_item.synchronizer.set_multiplayer_authority(id)
	inventory_item.name = 'Item_' + str(id)
	inventory_item.position = pos
	inventory_item.network_id = id
	inventory_item.slot_data = slot_data
	print('custom spawn called')
	return inventory_item

@rpc("any_peer", "call_local", "reliable")
func spawn_inventory_item(id: int, spawn_position : Vector3, serialized_slot_data : Dictionary) -> void:
	if not multiplayer.is_server(): return
	var slot_data = SerializationUtils.deserialize_in_slot_data(serialized_slot_data)
	spawn([id, spawn_position, serialized_slot_data])
	print("SERVER: " + slot_data.item.name + " item with id %d spawned at " % [id] + str(spawn_position))