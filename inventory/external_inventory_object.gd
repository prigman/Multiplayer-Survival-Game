class_name ExternalInventory extends StaticBody3D

const DEFAULT_MATERIAL = preload('res://materials/main_pallete.tres')
const TRUE_MATERIAL = preload('res://materials/main_pallete_material_true.tres')
const FALSE_MATERIAL = preload('res://materials/main_pallete_material_false.tres')

signal signal_building_spawn(player : Player)
signal signal_toggle_inventory(external_inventory_owner : ExternalInventory)

@export var inventory_data: InventoryData

@export var item_data : ItemDataCraftableBuildings
@export var shape_cast : ShapeCast3D
@export var collision_shape : CollisionShape3D
@export var mesh_node : MeshInstance3D
@export var building_part_owner_id : int
@export var building_collision : Area3D

var is_able_to_build : bool

func _player_interact(_inventory_data: InventoryData, _quick_slot_data: InventoryData) -> void:
	signal_toggle_inventory.emit(self)

func _on_signal_building_spawn() -> void:
	rpc("connect_to_inv")

@rpc("any_peer","call_local","reliable")
func connect_to_inv() -> void:
	for player in get_tree().get_nodes_in_group("player"):
		if player.peer_id == multiplayer.get_unique_id():
			signal_toggle_inventory.connect(player._toggle_inventory_interface)
			break