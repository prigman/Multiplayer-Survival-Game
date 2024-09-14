extends Control
class_name InventoryInterface

signal signal_drop_item(slot_data: InSlotData)
signal signal_use_item(slot_data: InSlotData)
signal signal_force_close
signal signal_item_info_panel_set_data(item_data: ItemData, slot_data : InSlotData)

#- set inventory
var external_inventory_owner : ExternalInventory

#- _on_inventory_interact
var grabbed_slot_data: InSlotData
var panel_index_data : int
var panel_inventory_data: InventoryData
var last_clicked_slot_data: InSlotData

@export var player: Player

@onready var player_inventory_ui := %PlayerInventory
@onready var player_quick_slot_ui := %PlayerQuickSlot
@onready var grabbed_slot := %GrabbedSlot
@onready var external_inventory := %ExternalInventory
@onready var inv_item_info_panel := %InvItemInfoPanel

func _physics_process(_delta : float) -> void:
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position() + Vector2(5, 5)
	
	if external_inventory_owner \
		and external_inventory_owner.global_position.distance_to(player.get_global_position()) > 4:
			signal_force_close.emit()

func _set_interact_player_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.signal_inventory_interact.connect(_on_inventory_interact)
	#inventory_data.signal_slot_mouse_right_clicked.connect(player_inventory._on_item_panel_visibility_changed)
	player_inventory_ui._set_inventory_data(inventory_data)
	
func _set_interact_quick_slot_data(inventory_data: InventoryData) -> void:
	inventory_data.signal_inventory_interact.connect(_on_inventory_interact)
	inventory_data.signal_update_active_slot.connect(player_quick_slot_ui._set_active_slot)
	#inventory_data.signal_slot_mouse_right_clicked.connect(player_quick_slot._on_item_panel_visibility_changed)
	player_quick_slot_ui._set_inventory_data(inventory_data)

func _set_external_inventory(inventory_owner : ExternalInventory) -> void:
	external_inventory_owner = inventory_owner
	var inventory_data : InventoryData = external_inventory_owner.inventory_data
	inventory_data.signal_inventory_interact.connect(_on_inventory_interact)
	#inventory_data.signal_slot_mouse_right_clicked.connect(external_inventory._on_item_panel_visibility_changed)
	external_inventory._set_inventory_data(inventory_data)
	external_inventory.show()
	
func _clear_external_inventory() -> void:
	if external_inventory_owner:
		var inventory_data : InventoryData = external_inventory_owner.inventory_data
		inventory_data.signal_inventory_interact.disconnect(_on_inventory_interact)
		external_inventory._clear_inventory_data(inventory_data)
		external_inventory.hide()
		external_inventory_owner = null
	
func _on_inventory_interact(inventory_data: InventoryData, index: int, button: int, player_peer_id : int) -> void:
	#print("START %s %s %s" % [inventory_data, index, button])
	if player.peer_id != player_peer_id: return
	match [grabbed_slot_data, button]:
		[null, MOUSE_BUTTON_LEFT]:
			if inventory_data.type == inventory_data.InventoryType.external_inventory and external_inventory_owner:
				rpc("RPC_change_slot_data_in_external_inventory", external_inventory_owner.get_path(), index, {}, {}, -1)
			if last_clicked_slot_data == inventory_data.slots_data[index] and inv_item_info_panel.visible:
				hide_inv_item_panel()
			grabbed_slot_data = inventory_data._grab_slot_data(index)
		
		[_, MOUSE_BUTTON_LEFT]:
			if inventory_data.type == inventory_data.InventoryType.external_inventory and external_inventory_owner:
				var dict_slot_data := grabbed_slot_data.serialize_data()
				var dict_item_data := grabbed_slot_data.item.serialize_item_data()
				rpc("RPC_change_slot_data_in_external_inventory", external_inventory_owner.get_path(), index, dict_slot_data, dict_item_data, grabbed_slot_data.item.id)
			if last_clicked_slot_data == inventory_data.slots_data[index] and inv_item_info_panel.visible:
				hide_inv_item_panel()
			grabbed_slot_data = inventory_data._drop_slot_data(grabbed_slot_data, index)
		[null, MOUSE_BUTTON_RIGHT]:
			#last_clicked_slot_index = index
			if inventory_data.slots_data[index] != null:
				if last_clicked_slot_data == inventory_data.slots_data[index] and inv_item_info_panel.visible:
					hide_inv_item_panel()
					last_clicked_slot_data = null
				else:
					if !inv_item_info_panel.visible:
						inv_item_info_panel.show()
					#inv_item_info_panel.global_position = get_global_mouse_position() + Vector2(5, -170)
					panel_index_data = index
					panel_inventory_data = inventory_data
					signal_item_info_panel_set_data.emit(inventory_data.slots_data[index].item, inventory_data.slots_data[index])
				last_clicked_slot_data = inventory_data.slots_data[index]
			else:
				if inv_item_info_panel.visible:
					hide_inv_item_panel()
		[_, MOUSE_BUTTON_RIGHT]:
			if inventory_data.type == inventory_data.InventoryType.external_inventory and external_inventory_owner:
				var dict_slot_data := grabbed_slot_data.serialize_data()
				var dict_item_data := grabbed_slot_data.item.serialize_item_data()
				rpc("RPC_change_slot_data_in_external_inventory", external_inventory_owner.get_path(), index, dict_slot_data, dict_item_data, grabbed_slot_data.item.id, true)
			grabbed_slot_data = inventory_data._drop_single_slot_data(grabbed_slot_data, index)
	
	var dict_grabbed_slot_data : Dictionary
	var dict_grabbed_item_data : Dictionary
	var grabbed_slot_item_id : int = -1
	if grabbed_slot_data:
		dict_grabbed_slot_data = grabbed_slot_data.serialize_data()
		dict_grabbed_item_data = grabbed_slot_data.item.serialize_item_data()
		grabbed_slot_item_id = grabbed_slot_data.item.id
	
	if inventory_data.type == inventory_data.InventoryType.quick_slot:
		player.serialized_player_quick_slot = inventory_data.serialize_inventory_data()
		print("SERVER serialized_player_quick_slot: ", str(player.serialized_player_quick_slot))
	else:
		player.serialized_player_inventory = inventory_data.serialize_inventory_data()
		print("SERVER serialized_player_inventory: ", str(player.serialized_player_inventory))
	rpc_id(player_peer_id, "RPC_update_grabbed_slot", dict_grabbed_slot_data, dict_grabbed_item_data, grabbed_slot_item_id,inventory_data.type, player.serialized_player_quick_slot)
	#
	# _update_grabbed_slot()

	if inventory_data.type == inventory_data.InventoryType.quick_slot \
		and player.item.equiped_slot and player.item.equiped_slot == grabbed_slot_data:
		player.item.swap_items(inventory_data, index)

@rpc("any_peer", "call_local", "reliable", 2)
func RPC_change_slot_data_in_external_inventory(external_inventory_path : NodePath, index : int, dict_slot_data : Dictionary, dict_item_data : Dictionary, item_id : int, is_single_slot : bool = false) -> void:
	if multiplayer.get_unique_id() == player.peer_id: return
	var node : StaticBody3D = get_node(external_inventory_path)
	if not dict_slot_data.is_empty() and not dict_item_data.is_empty() and item_id != -1:
		#var item_data := AllGameInventoryItems.load_item_data_by_id(item_id).duplicate(true)
		#var new_slot_data : InSlotData = node.inventory_data._create_new_slot(dict_slot_data["amount_in_slot"], item_data)
		#new_slot_data.item.deserialize_item_data(dict_item_data)
		var new_slot_data := AllGameInventoryItems.deserialize_slot_and_item_data(dict_slot_data, dict_item_data, item_id, node.inventory_data)
		if not is_single_slot:
			# print("item id: ", str(item_id))
			node.inventory_data._drop_slot_data(new_slot_data, index)
		else:
			node.inventory_data._drop_single_slot_data(new_slot_data, index)
	else:
		node.inventory_data._remove_slot_data(index)
	node.on_player_connect_inventory_data = node.inventory_data.serialize_inventory_data()

func _update_grabbed_slot() -> void:
	if grabbed_slot_data:
		grabbed_slot.show()
		grabbed_slot._set_slot_data(grabbed_slot_data)
	else:
		grabbed_slot.hide()

@rpc("any_peer", "call_local", "reliable", 2)
func RPC_update_grabbed_slot(serialized_slot_data : Dictionary, serialized_item_data : Dictionary, item_id : int, inventory_type : int, serialized_inventory : Dictionary) -> void:
	if not serialized_item_data.is_empty() and not serialized_item_data.is_empty() and item_id != -1:
		grabbed_slot_data = AllGameInventoryItems.deserialize_slot_and_item_data(serialized_slot_data, serialized_item_data, item_id)

		grabbed_slot.show()
		grabbed_slot._set_slot_data(grabbed_slot_data)

		if inventory_type == player.player_quick_slot.type:
			player.player_quick_slot.deserialize_inventory_data(serialized_inventory)
			player.player_quick_slot._update_inventory()
			print("serialized_player_quick_slot: ", str(player.serialized_player_quick_slot))
		else:
			player.player_inventory.deserialize_inventory_data(serialized_inventory)
			player.player_inventory._update_inventory()
			print("serialized_player_inventory: ", str(player.serialized_player_inventory))

		print("serialized_data: ", str(serialized_inventory))

	else:
		grabbed_slot.hide()

func _on_visibility_changed() -> void: #TODO
	if not visible and grabbed_slot_data:
		signal_drop_item.emit(grabbed_slot_data)
		grabbed_slot_data = null
		_update_grabbed_slot()

func _on_item_drop_button_pressed() -> void:
	# if multiplayer.is_server(): return #
	if panel_inventory_data.type == panel_inventory_data.InventoryType.external_inventory and external_inventory_owner:
		rpc("RPC_change_slot_data_in_external_inventory", external_inventory_owner.get_path(), panel_index_data, {}, {}, 0)
	if player.item.equiped_slot == panel_inventory_data.slots_data[panel_index_data]:
		player.item.clear_item(panel_inventory_data, panel_index_data, panel_inventory_data.slots_data[panel_index_data])
	signal_drop_item.emit(panel_inventory_data.slots_data[panel_index_data])
	panel_inventory_data._grab_slot_data(panel_index_data)
	hide_inv_item_panel()

func _on_item_use_button_pressed() -> void:
	# if multiplayer.is_server(): return #
	if panel_inventory_data.type == panel_inventory_data.InventoryType.external_inventory and external_inventory_owner:
		rpc("RPC_change_slot_data_in_external_inventory", external_inventory_owner.get_path(), panel_index_data, {}, {}, 0)
	if player.item.equiped_slot == panel_inventory_data.slots_data[panel_index_data]:
		player.item.clear_item(panel_inventory_data, panel_index_data, panel_inventory_data.slots_data[panel_index_data])
	signal_use_item.emit(panel_inventory_data.slots_data[panel_index_data])
	panel_inventory_data._grab_slot_data(panel_index_data)
	hide_inv_item_panel()

func _on_gui_input(event : InputEvent) -> void:
	# if multiplayer.is_server(): return
	if event is InputEventMouseButton \
			and event.is_pressed():
		match event.button_index:
			MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT:
				if grabbed_slot_data:
					signal_drop_item.emit(grabbed_slot_data)
					grabbed_slot_data = null
				if inv_item_info_panel.visible:
					hide_inv_item_panel()
		_update_grabbed_slot() 

func hide_inv_item_panel() -> void:
	inv_item_info_panel.hide()
	panel_index_data = 0
	panel_inventory_data = null

func _on_divide_content_signal_divide_button_pressed(item_amount:int) -> void:
	if grabbed_slot_data:
		return
	else:
		var number := panel_inventory_data.slots_data[panel_index_data].amount_in_slot - item_amount
		panel_inventory_data._set_amount_in_slot(panel_index_data, number)
		var new_slot : InSlotData = panel_inventory_data.slots_data[panel_index_data].duplicate()
		new_slot.amount_in_slot = item_amount
		grabbed_slot.show()
		grabbed_slot._set_slot_data(new_slot)
		grabbed_slot_data = new_slot
		signal_item_info_panel_set_data.emit(panel_inventory_data.slots_data[panel_index_data].item, panel_inventory_data.slots_data[panel_index_data])
