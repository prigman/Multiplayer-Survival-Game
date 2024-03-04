extends Node

var global_debug
var global_player : Player
var global_player_quick_slot : InventoryData

func get_global_position() -> Vector3:
	return global_player.global_position
	
func check_is_inventory_open() -> bool:
	return global_player.inventory_interface.visible
