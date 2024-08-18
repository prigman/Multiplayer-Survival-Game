extends StaticBody3D

signal signal_toggle_inventory(external_inventory_owner : Player)

@export var inventory_data: InventoryData

@export var shape_cast : ShapeCast3D
var building_part_owner : Player

func _player_interact(_inventory_data: InventoryData, _quick_slot_data: InventoryData) -> void:
	signal_toggle_inventory.emit(self)
