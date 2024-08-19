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
var was_spawned : bool

func _player_interact(_inventory_data: InventoryData, _quick_slot_data: InventoryData) -> void:
	signal_toggle_inventory.emit(self)

func _on_signal_building_spawn(player : Player) -> void:
	player.rpc("connect_external_inventory_signal_to_player", name)