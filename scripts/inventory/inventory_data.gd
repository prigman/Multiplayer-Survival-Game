extends Node
class_name InventoryNode

enum InventoryType
{
	player_inventory,
	quick_slot,
	external_inventory
}

signal signal_inventory_interact(inventory_data : InventoryNode, index : int, button : int, peer_id : int)
signal signal_inventory_update(inventory_data : InventoryNode)
signal signal_update_active_slot(inventory_data : InventoryNode, new_slot_data : InSlotData, last_slot_data : InSlotData)
signal player_connected_set_slots_data(id : int)


#signal signal_slot_mouse_right_clicked(inventory_data : InventoryData, last_inventory_data : InventoryData, clicked_slot_index : int, last_slot_index : int, panel_visible : bool)
@export var sync_inventory_between_players : bool
@export var type : InventoryType
@export var slots_data: Array[InSlotData]
var slot_copy : InSlotData = null

@export var serialized_slots_data : Dictionary :
	set(value) :
		serialized_slots_data = value
		if not multiplayer.is_server():
			deserialize_inventory_data(value)

# var slots_sync : Array:
# 	set(value):
# 		slots_sync = value
# 		if not multiplayer.is_server():
# 			for i in range(slots_sync.size(), slots_data.size()):
# 				slots_data.remove_at(i)
# 			for i in slots_sync.size():
# 				if i >= slots_data.size():
# 					var slot := InSlotData.new()
# 					slots_data.append(slot)
# 				slots_data[i].amount_in_slot = slots_sync[i].amount_in_slot
# 				var item := AllGameInventoryItems.load_item_data_by_id(slots_sync[i].item_id)
# 				slots_data[i].item = item

func _ready() -> void:
	# multiplayer.peer_connected.connect(_on_connected)
	# if not serialized_slots_data.is_empty():
	# 	deserialize_inventory_data(serialized_slots_data)
	# else:
		
			# signal_inventory_update.emit(self)
			# serialize_inventory_data()
	# if not multiplayer.is_server(): return
	# if slots_data.is_empty(): return
	# for slot in slots_data:
	# 	if slot and slot.item:
	# 		var new_slot := InSlotData.new()
	# 		var duplicated_item := slot.item.duplicate(true)
	# 		new_slot.item = duplicated_item
	# 		new_slot.amount_in_slot = slot.amount_in_slot
	# 		slot = new_slot
	# serialize_inventory_data()
	player_connected_set_slots_data.connect(on_player_connected_set_slots_data)

func on_player_connected_set_slots_data(id : int) -> void:
	rpc_id(1, "RPC_set_inventory_data", id)
	# if not multiplayer.is_server(): return


@rpc("any_peer", "call_local", "reliable", 2)
func RPC_set_inventory_data(id : int) -> void:
	serialize_inventory_data(id)
	# rpc_id(id, "RPC_serialize_data", serialized_slots_data)
# func _on_connected(_id : int) -> void:
	# if not multiplayer.is_server(): return
	# if slots_data.is_empty(): return
	# for slot in slots_data:
	# 	if slot and slot.item:
	# 		var new_slot := InSlotData.new()
	# 		var duplicated_item := slot.item.duplicate(true)
	# 		new_slot.item = duplicated_item
	# 		new_slot.amount_in_slot = slot.amount_in_slot
	# 		slot = new_slot
	# serialize_inventory_data()
	# rpc_id(id, "RPC_serialize_data", serialized_slots_data)

func _update_inventory() -> void:
	signal_inventory_update.emit(self)

func _set_amount_in_slot(index : int, amount : int) -> void:
	var slot := slots_data[index]
	slot.amount_in_slot = amount
	signal_inventory_update.emit(self)

func _remove_slot_data(index : int) -> bool:
	var slot := slots_data[index]
	if slot:
		slots_data[index] = null
		signal_inventory_update.emit(self)
		return true
	else:
		return false

func _grab_slot_data(index : int) -> InSlotData:
	var slot := slots_data[index]
	if slot:
		slots_data[index] = null
		signal_inventory_update.emit(self)
		return slot
	else:
		return null

func _drop_slot_data(grabbed_slot_data : InSlotData, index : int) -> InSlotData:
	var slot := slots_data[index]
	var return_slot_data : InSlotData

	if slot and slot._can_stack_with(grabbed_slot_data):
		var space_left := slot.item.max_stack - slot.amount_in_slot
		var stack_amount : int = min(space_left, grabbed_slot_data.amount_in_slot)
		slot.amount_in_slot += stack_amount
		grabbed_slot_data.amount_in_slot -= stack_amount
		
		if grabbed_slot_data.amount_in_slot == 0:
			return_slot_data = null
		else:
			return_slot_data = grabbed_slot_data
	else:
		slots_data[index] = grabbed_slot_data
		return_slot_data = slot
	
	signal_inventory_update.emit(self)
	return return_slot_data

func _drop_single_slot_data(grabbed_slot_data : InSlotData, index : int) -> InSlotData:
	var slot := slots_data[index]
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
	var remaining_amount := slot_data.amount_in_slot

	for i in slots_data.size():
		if slots_data[i] and slots_data[i]._can_stack_with(slot_data):
			var space_left := slots_data[i].item.max_stack - slots_data[i].amount_in_slot
			var stack_amount : int = min(space_left, remaining_amount)
			slots_data[i].amount_in_slot += stack_amount
			remaining_amount -= stack_amount
			if remaining_amount == 0:
				signal_inventory_update.emit(self)
				return true

	for i in slots_data.size():
		if not slots_data[i]:
			slot_copy = slot_data.duplicate()
			slot_copy.amount_in_slot = remaining_amount
			slots_data[i] = slot_copy
			signal_inventory_update.emit(self)
			return true

	for i in slots_data.size():
		if not slots_data[i]:
			slot_copy = slot_data.duplicate()
			slot_copy.amount_in_slot = remaining_amount
			slots_data[i] = slot_copy
			signal_inventory_update.emit(self)
			return true

	print("Player inventory is full")
	return false
	
func _on_slot_clicked(index : int, button : int, peer_id : int) -> void:
	print("inventory data interact from authority: ", multiplayer.get_unique_id())
	rpc("RPC_player_interacted_with_inventory", index, button, peer_id)
	# signal_inventory_interact.emit(self, index, button, peer_id)

@rpc("any_peer", "call_local", "reliable", 2)
func RPC_player_interacted_with_inventory(slot_index : int, button_index : int, peer_id : int) -> void:
	if multiplayer.is_server() or multiplayer.get_unique_id() == peer_id:
		print("RPC_intreacted from authority: ", multiplayer.get_unique_id())
		signal_inventory_interact.emit(self, slot_index, button_index, peer_id)
		# rpc_id(peer_id, "RPC_player_interacted_with_inventory", slot_index, button_index, peer_id)

func _create_new_slot_data(amount_in_slot : int, item_data : Resource) -> InSlotData:
	var slot := InSlotData.new()
	slot.item = item_data
	slot.amount_in_slot = amount_in_slot
	return slot

# func _set_slot_data(index : int, slot_data : InSlotData) -> bool:
# 	if slot_data:
# 		slots_data[index] = slot_data
# 		signal_inventory_update.emit(self)
# 		return true
# 	else:
# 		return false

func serialize_inventory_data(peer_id : int = -1) -> void:
	var serialized_data : Dictionary
	# serialized_data["type"] = type
	
	for i : int in range(slots_data.size()):
		if not slots_data[i] or not slots_data[i].item: continue
		var slot_key := "slot_" + str(i)
		
		var slot_data_dict : Dictionary
		
		slot_data_dict["slot_id"] = i
		slot_data_dict["item_id_in_slot"] = slots_data[i].item.id
		if slots_data[i].item.has_method("serialize_item_data"):
			slot_data_dict["item_serialized_data"] = slots_data[i].item.serialize_item_data()
		slot_data_dict["amount_in_slot"] = slots_data[i].amount_in_slot
		serialized_data[slot_key] = slot_data_dict
	print("serialize on inventory: ", str(get_path()))
	# serialized_slots_data = serialized_data
	# if deserialize_local:
		# serialized_slots_data = serialized_data
	# else:
	# if not deserialize_local:
	# serialized_slots_data = serialized_data
	# return serialized_data
	# else:
	if peer_id != -1:
		serialized_slots_data = serialized_data
		rpc_id(peer_id, "RPC_deserialize_data", serialized_data)
	elif peer_id == -1:
		rpc("RPC_deserialize_data", serialized_data)


@rpc("any_peer", "call_local", "reliable", 2)
func RPC_deserialize_data(serialized_data : Dictionary) -> void:
	# var inventory_node := get_node(inventory_node_path)
	# print("RPC_serlialized_data inventory-path: " + str(get_path()) + " on: ", multiplayer.get_unique_id())
	# if multiplayer.is_server():
	serialized_slots_data = serialized_data
	# deserialize_inventory_data(serialized_data)
	# else:
		# deserialize_inventory_data(serialized_data)

func deserialize_inventory_data(serialized_inventory_data : Dictionary) -> void:
	for i in range(slots_data.size()):
		if slots_data[i]: slots_data[i] = null
	for slot_key : String in serialized_inventory_data.keys():
		# print(str(slot_data_dict))
		if serialized_inventory_data[slot_key] is not Dictionary: continue
		var slot_data_dict : Dictionary = serialized_inventory_data[slot_key]
		var slot_id : int = slot_data_dict["slot_id"]
		if slot_id < slots_data.size():
			var slot_item_data := AllGameInventoryItems.load_item_data_by_id(slot_data_dict["item_id_in_slot"]).duplicate(true)
			# var new_slot_data : InSlotData = _create_new_slot_data(slot_data_dict["amount_in_slot"], slot_item_data)
			if slot_item_data.has_method("deserialize_item_data"):
				slot_item_data.deserialize_item_data(slot_data_dict["item_serialized_data"])
			# _set_slot_data(slot_id, new_slot_data)
			slots_data[slot_id] = _create_new_slot_data(slot_data_dict["amount_in_slot"], slot_item_data)
	signal_inventory_update.emit(self)
	print("data deserialized on inventory: " + str(get_path()) + " on client: ", multiplayer.get_unique_id())

func _clear_inventory() -> void:
	for slot in slots_data:
		if slot and slot.amount_in_slot > 0:
			slot.amount_in_slot = 0
	signal_inventory_update.emit(self)
