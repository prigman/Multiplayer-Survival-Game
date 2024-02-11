extends StaticBody3D

signal signal_toggle_inventory(external_inventory_owner)

@export var inventory_data : InventoryData

func _player_interact(_inventory_data : InventoryData):
	signal_toggle_inventory.emit(self)
