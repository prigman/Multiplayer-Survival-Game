extends Resource
class_name InventoryData

enum InventoryType
{
	player_inventory,
	quick_slot,
	external_inventory
}

signal signal_inventory_interact(inventory_data : InventoryData, index : int, button : int)
signal signal_inventory_update(inventory_data : InventoryData)
signal signal_update_active_slot(inventory_data : InventoryData, new_slot_index : int, last_slot_index : int, new_slot_data : InSlotData, last_slot_data : InSlotData)

#signal signal_slot_mouse_right_clicked(inventory_data : InventoryData, last_inventory_data : InventoryData, clicked_slot_index : int, last_slot_index : int, panel_visible : bool)

@export var type : InventoryType
@export var slots_data: Array[InSlotData]

func _grab_slot_data(index : int) -> InSlotData:
	var slot = slots_data[index]
	if slot:
		slots_data[index] = null
		signal_inventory_update.emit(self)
		return slot
	else:
		return null

func _drop_slot_data(grabbed_slot_data : InSlotData, index : int) -> InSlotData:
	var slot = slots_data[index]
	var return_slot_data : InSlotData
	if slot and slot._can_fully_stack_with(grabbed_slot_data):
		slot._stack_with(grabbed_slot_data)
	else:
		slots_data[index] = grabbed_slot_data
		return_slot_data = slot
	signal_inventory_update.emit(self)
	return return_slot_data

func _drop_single_slot_data(grabbed_slot_data : InSlotData, index : int) -> InSlotData:
	var slot = slots_data[index]
	if not slot:
		slots_data[index] = grabbed_slot_data._create_single_slot_data()
	elif slot._can_stack_with(grabbed_slot_data):
		slot._stack_with(grabbed_slot_data._create_single_slot_data())
	signal_inventory_update.emit(self)
	if grabbed_slot_data.amount_in_slot > 0:
		return grabbed_slot_data
	else:
		return null
	
func _pick_up_slot_data(slot_data : InSlotData) -> bool:
		
	for i in slots_data.size():
		if slots_data[i] and slots_data[i]._can_stack_with(slot_data):
			slots_data[i]._stack_with(slot_data)
			signal_inventory_update.emit(self)
			return true
			
	for i in slots_data.size():
		if not slots_data[i]:
			slots_data[i] = slot_data
			signal_inventory_update.emit(self)
			return true
	return false
	
func _on_slot_clicked(index : int, button : int):
	signal_inventory_interact.emit(self, index, button)

