extends Node
class_name World

@onready var player = $Player

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.signal_toggle_inventory.connect(_toggle_inventory_interface)
	player.inventory_interface._set_player_inventory_data(player.player_inventory)
	player.inventory_interface._set_quick_slot_data(player.player_quick_slot)
	player.inventory_interface.signal_drop_item.connect(_on_inventory_interface_signal_drop_item)
	player.inventory_interface.signal_force_close.connect(_toggle_inventory_interface)
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.signal_toggle_inventory.connect(_toggle_inventory_interface)

func _process(_delta):
	if(player.position.y <= -10.0):
		get_tree().reload_current_scene()

func _input(_event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _toggle_inventory_interface(external_inventory_owner = null):
	player.inventory_interface.visible = not player.inventory_interface.visible
	if player.inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if player.inventory_interface.inv_item_info_panel.visible:
		player.inventory_interface.inv_item_info_panel.hide()
	if external_inventory_owner and player.inventory_interface.visible:
		player.inventory_interface._set_external_inventory(external_inventory_owner)
	else:
		player.inventory_interface._clear_external_inventory()

func _on_inventory_interface_signal_drop_item(slot_data):
	if slot_data.item.dictionary.has("dropped_item"):
		var dropped_slot = load(slot_data.item.dictionary["dropped_item"])
		if player.inventory_interface.inv_item_info_panel.visible:
			player.inventory_interface.inv_item_info_panel.hide()
		_instantiate_dropped_item(dropped_slot, slot_data)

func _instantiate_dropped_item(dropped_slot : PackedScene, slot_data : InSlotData):
	var obj = dropped_slot.instantiate()
	obj.slot_data = slot_data
	obj.position = player.get_drop_position()
	add_child(obj)
