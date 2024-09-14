class_name ExternalInventory extends StaticBody3D

const DEFAULT_MATERIAL = preload('res://materials/main_pallete.tres')
const TRUE_MATERIAL = preload('res://materials/main_pallete_material_true.tres')
const FALSE_MATERIAL = preload('res://materials/main_pallete_material_false.tres')

signal signal_building_spawn(player : Player)
signal signal_toggle_inventory(external_inventory_owner : ExternalInventory)

@export var inventory_data: InventoryData
@export var on_player_connect_inventory_data : Dictionary

@export var item_data : ItemDataCraftableBuildings
@export var shape_cast : ShapeCast3D
@export var collision_shape : CollisionShape3D
# @export var collision_shape_2 : CollisionShape3D
@export var mesh_node : MeshInstance3D
@export var building_part_owner_id : int
@export var building_collision : Area3D
@export var was_build : bool


var is_able_to_build : bool


func _ready() -> void:
	if was_build:
		if on_player_connect_inventory_data == {}: return
		inventory_data.deserialize_inventory_data(on_player_connect_inventory_data) # выполняется для всех серверных игроков на сервере
		if not multiplayer.is_server(): inventory_data._update_inventory()
		#for slot_key : String in on_player_connect_inventory_data.keys():
			## print(str(slot_data_dict))
			#if on_player_connect_inventory_data[slot_key] is int: continue
			#var slot_data_dict : Dictionary = on_player_connect_inventory_data[slot_key]
			#var slot_id : int = slot_data_dict["slot_id"]
			#if slot_id <= inventory_data.slots_data.size():
				#var slot_item_data := AllGameInventoryItems.load_item_data_by_id(slot_data_dict["item_id_in_slot"]).duplicate(true)
				#var new_slot_data : InSlotData = inventory_data._create_new_slot(slot_data_dict["amount_in_slot"], slot_item_data)
				#if slot_item_data.has_method("deserialize_item_data"):
					#slot_item_data.deserialize_item_data(slot_data_dict["item_serialized_data"])
				#inventory_data._set_slot_data(slot_id, new_slot_data)

func _player_interact() -> void:
	signal_toggle_inventory.emit(self)

func _on_signal_building_spawn() -> void:
	was_build = true
	rpc("connect_to_inv")

@rpc("any_peer","call_local","reliable")
func connect_to_inv() -> void:
	if multiplayer.is_server(): return
	for player in get_tree().get_nodes_in_group("player"):
		if player.peer_id == multiplayer.get_unique_id():
			signal_toggle_inventory.connect(player._toggle_inventory_interface)
			break

@rpc("any_peer", "call_local", "reliable", 2)
func RPC_external_inventory_interact() -> void:
	signal_toggle_inventory.emit(self)
