extends Node

var global_debug
var global_player : Player
var global_player_quick_slot : InventoryData
var global_player_inventory : InventoryData
var global_item_script : ItemScript

func get_global_position() -> Vector3:
	return global_player.global_position
	
func check_is_inventory_open() -> bool:
	return global_player.inventory_interface.visible
