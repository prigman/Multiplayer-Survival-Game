extends Control
class_name InventoryInterface

signal signal_drop_item(slot_data: InSlotData)
signal signal_force_close
signal signal_item_info_panel_set_data(item_data: ItemData)

#- set inventory
var external_inventory_owner : ExternalInventory

#- _on_inventory_interact
var grabbed_slot_data: InSlotData
var panel_index_data : int
var panel_inventory_data: InventoryData
var last_clicked_slot_data: InSlotData

@export var player: Player

@onready var player_inventory := %PlayerInventory
@onready var player_quick_slot := %PlayerQuickSlot
@onready var grabbed_slot := %GrabbedSlot
@onready var external_inventory := %ExternalInventory
@onready var inv_item_info_panel := %InvItemInfoPanel

func _physics_process(_delta : float) -> void:
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position() + Vector2(5, 5)
	
	if external_inventory_owner \
		and external_inventory_owner.global_position.distance_to(player.get_global_position()) > 4:
			signal_force_close.emit()

func _set_player_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.signal_inventory_interact.connect(_on_inventory_interact)
	#inventory_data.signal_slot_mouse_right_clicked.connect(player_inventory._on_item_panel_visibility_changed)
	player_inventory._set_inventory_data(inventory_data)
	
func _set_quick_slot_data(inventory_data: InventoryData) -> void:
	inventory_data.signal_inventory_interact.connect(_on_inventory_interact)
	inventory_data.signal_update_active_slot.connect(player_quick_slot._set_active_slot)
	#inventory_data.signal_slot_mouse_right_clicked.connect(player_quick_slot._on_item_panel_visibility_changed)
	player_quick_slot._set_inventory_data(inventory_data)

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
	
func _on_inventory_interact(inventory_data: InventoryData, index: int, button: int) -> void:
	#print("START %s %s %s" % [inventory_data, index, button])
	match [grabbed_slot_data, button]:
		[null, MOUSE_BUTTON_LEFT]:
			if last_clicked_slot_data == inventory_data.slots_data[index] and inv_item_info_panel.visible:
				if inv_item_info_panel.visible:
					hide_inv_item_panel()
			grabbed_slot_data = inventory_data._grab_slot_data(index)
			# rpc("RPC_grab_slot", inventory_data.type, index)
		[_, MOUSE_BUTTON_LEFT]:
			if last_clicked_slot_data == inventory_data.slots_data[index] and inv_item_info_panel.visible:
				if inv_item_info_panel.visible:
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
					signal_item_info_panel_set_data.emit(inventory_data.slots_data[index].item)
				last_clicked_slot_data = inventory_data.slots_data[index]
			else:
				if inv_item_info_panel.visible:
					hide_inv_item_panel()
		[_, MOUSE_BUTTON_RIGHT]:
			grabbed_slot_data = inventory_data._drop_single_slot_data(grabbed_slot_data, index)
	_update_grabbed_slot()
	if inventory_data.type == inventory_data.InventoryType.quick_slot \
		and player.item.equiped_slot and player.item.equiped_slot == grabbed_slot_data:
		player.item.swap_items(inventory_data, index)

# @rpc("any_peer", "call_local", "reliable")
# func RPC_grab_slot(inventory_type : int, index : int) -> void:
# 	if is_multiplayer_authority(): return
# 	print("null")
# 	if external_inventory_owner == null: return
# 	print("not null")
# 	if inventory_type == external_inventory_owner.inventory_data.InventoryType.external_inventory:
# 		external_inventory_owner.inventory_data.slots_data[index] = null
# 		external_inventory_owner.inventory_data._update_inventory()
# 		# inventory_data._update_inventory()

func _update_grabbed_slot() -> void:
	if grabbed_slot_data:
		grabbed_slot.show()
		grabbed_slot._set_slot_data(grabbed_slot_data)
	else:
		grabbed_slot.hide()

func _on_visibility_changed() -> void:
	if not visible and grabbed_slot_data:
		signal_drop_item.emit(grabbed_slot_data)
		grabbed_slot_data = null
		_update_grabbed_slot()

func _on_item_drop_button_pressed() -> void:
	if player.item.equiped_slot == panel_inventory_data.slots_data[panel_index_data]:
		player.item.remove_active_item(panel_inventory_data, panel_index_data, panel_inventory_data.slots_data[panel_index_data])
	signal_drop_item.emit(panel_inventory_data.slots_data[panel_index_data])
	panel_inventory_data._grab_slot_data(panel_index_data)
	hide_inv_item_panel()

func _on_gui_input(event : InputEvent) -> void:
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
