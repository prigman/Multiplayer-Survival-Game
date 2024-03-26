extends Node

var global_debug
var global_player : Player
var global_player_quick_slot : InventoryData
var global_player_inventory : InventoryData
var global_item_script : ItemScript
var global_world : World 

func get_global_position() -> Vector3:
	return global_player.global_position
	
func check_is_inventory_open() -> bool:
	return global_player.inventory_interface.visible
	
func get_player_inventory_slots() -> Array[InSlotData]:
	if !global_player_inventory:
		push_error("Set player_inventory in Player node")
		return []
	return global_player_inventory.slots_data

func get_player_quick_slots() -> Array[InSlotData]:
	if !global_player_quick_slot:
		push_error("Set player_quick_slot in Player node")
		return []
	return global_player_quick_slot.slots_data
	
func give_player_item(slot_data : InSlotData):
	if !global_player_inventory._pick_up_slot_data(slot_data) \
		and !global_player_quick_slot._pick_up_slot_data(slot_data):
		global_player.inventory_interface.signal_drop_item.emit(slot_data)

