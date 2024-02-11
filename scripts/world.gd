extends Node

@onready var player = $Player
@onready var inventory_interface = $UI/Control/InventoryInterface

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.signal_toggle_inventory.connect(_toggle_inventory_interface)
	inventory_interface._set_player_inventory_data(player.player_inventory)
	inventory_interface._set_quick_slot_data(player.player_quick_slot)
	inventory_interface.signal_force_close.connect(_toggle_inventory_interface)
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.signal_toggle_inventory.connect(_toggle_inventory_interface)

func _process(_delta):
	if(player.position.y <= -10.0):
		get_tree().reload_current_scene()

func _input(_event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		

func _toggle_inventory_interface(external_inventory_owner = null):
	inventory_interface.visible = not inventory_interface.visible
	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if external_inventory_owner and inventory_interface.visible:
		inventory_interface._set_external_inventory(external_inventory_owner)
	else:
		inventory_interface._clear_external_inventory()


func _on_inventory_interface_signal_drop_slot_data(slot_data):
	if slot_data.item.properties.has("dropped_item"):
		var dropped_slot = load(slot_data.item.properties["dropped_item"])
		_instantiate_dropped_item(dropped_slot, slot_data)

func _instantiate_dropped_item(dropped_slot : PackedScene, slot_data : InSlotData):
	var obj = dropped_slot.instantiate()
	obj.slot_data = slot_data
	obj.position = player.get_drop_position()
	add_child(obj)
	#dropped.emit(obj)
