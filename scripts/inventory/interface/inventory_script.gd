class_name InventoryScript extends PanelContainer

const SLOT_SCENE := preload("res://scenes/interface/inventory/inventory_slot.tscn")
@onready var grid_container := %GridContainer
var slot_counter : int

func _set_inventory_data(inventory_data : InventoryNode) -> void:
	if not multiplayer.is_server(): 
		inventory_data.signal_inventory_update.connect(_set_player_inventory_slots)
		inventory_data.player_connected_set_slots_data.emit(multiplayer.get_unique_id())
		# _set_player_inventory_slots(inventory_data)
	else:
		# inventory_data.signal_inventory_update.connect(_set_server_inventory_slots_data) 
		# _set_server_inventory_slots_data(inventory_data)
		_set_start_inventory_slots_data(inventory_data)

func _clear_inventory_data(inventory_data : InventoryNode) -> void:
	inventory_data.signal_inventory_update.disconnect(_set_player_inventory_slots)

func _set_player_inventory_slots(inventory_data : InventoryNode) -> void:
	# for i in range(inventory_data.slots_data.size()):
	# 	var slot_data := inventory_data.slots_data[i]
	# 	if slot_data and slot_data.amount_in_slot == 0:
	# 		inventory_data.slots_data[i] = null
			
	for child in grid_container.get_children():
		child.queue_free()
		
	for slot_data in inventory_data.slots_data:
		var slot := SLOT_SCENE.instantiate()
		grid_container.add_child(slot)
		
		if slot_data and slot_data.amount_in_slot:
			if slot_data.active_slot_data:
					slot.active_slot_panel.show()
			slot._set_slot_data(slot_data)
			
		if inventory_data.type == inventory_data.InventoryType.quick_slot:
			slot_counter += 1
			slot.slot_number.text = str(slot_counter)
			slot.slot_number.show()
			
		slot.signal_slot_clicked.connect(inventory_data._on_slot_clicked)
	slot_counter = 0

func _set_server_inventory_slots_data(inventory_data : InventoryNode) -> void:
	for i in range(inventory_data.slots_data.size()):
		var slot_data := inventory_data.slots_data[i]
		if slot_data and slot_data.amount_in_slot == 0:
			inventory_data.slots_data[i] = null

func _set_start_inventory_slots_data(inventory_data : InventoryNode) -> void:
	if inventory_data.slots_data.is_empty(): return
	for slot : InSlotData in inventory_data.slots_data:
		if slot and slot.item:
			var new_slot := InSlotData.new()
			var duplicated_item := slot.item.duplicate(true)
			new_slot.item = duplicated_item
			new_slot.amount_in_slot = slot.amount_in_slot
			slot = new_slot

func _set_active_slot(inventory_data : InventoryNode, new_slot_data : InSlotData, last_slot_data : InSlotData) -> void:
	# print("id active set: ", multiplayer.get_unique_id())
	# var new_active_slot := grid_container.get_child(new_slot_index)
	# var last_active_slot := grid_container.get_child(last_slot_index)
	if new_slot_data and !last_slot_data:
		# if not multiplayer.is_server(): new_active_slot.active_slot_panel.show()
		new_slot_data.active_slot_data = true
		print("Active slot set: %s" % new_slot_data.item.name)
	if new_slot_data and last_slot_data:
		if new_slot_data == last_slot_data:
			# if not multiplayer.is_server(): new_active_slot.active_slot_panel.hide()
			new_slot_data.active_slot_data = false
			print("Active slot hided")
		else:
			# if not multiplayer.is_server(): last_active_slot.active_slot_panel.hide()
			last_slot_data.active_slot_data = false
			# if not multiplayer.is_server(): new_active_slot.active_slot_panel.show()
			new_slot_data.active_slot_data = true
			print("Active slot changed to %s" % new_slot_data.item.name)
	if !new_slot_data and last_slot_data:
		# if not multiplayer.is_server(): last_active_slot.active_slot_panel.hide()
		last_slot_data.active_slot_data = false
		print("Active slot hided")
	inventory_data._update_inventory()
