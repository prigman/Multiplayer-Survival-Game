class_name World extends Node

@onready var player = $Player

@export var enemy1 : CharacterBody3D
@export var enemy2 : CharacterBody3D
@export var enemy3 : CharacterBody3D

func _ready():
	Global.global_world = self
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
		player.craft_menu.custom_minimum_size.y = 460
		player.craft_menu_margin.add_theme_constant_override("margin_bottom", 190)
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if player.inventory_interface.inv_item_info_panel.visible:
		player.inventory_interface.inv_item_info_panel.hide()
	if external_inventory_owner and player.inventory_interface.visible:
		player.craft_menu.custom_minimum_size.y = 260
		player.craft_menu_margin.add_theme_constant_override("margin_bottom", 390)
		player.inventory_interface._set_external_inventory(external_inventory_owner)
	else:
		player.inventory_interface._clear_external_inventory()

func _on_inventory_interface_signal_drop_item(slot_data):
	if slot_data.item.dictionary.has("dropped_item"):
		var dropped_slot = load(slot_data.item.dictionary["dropped_item"])
		_instantiate_dropped_item(dropped_slot, slot_data)

func _instantiate_dropped_item(dropped_slot : PackedScene, slot_data : InSlotData):
	var obj = dropped_slot.instantiate()
	obj.slot_data = slot_data
	obj.position = player.get_drop_position()
	add_child(obj)


func _on_enemy_spawn_timer_timeout():
	if !enemy1.visible:
		enemy1.show()
	if !enemy2.visible:
		enemy2.show()
	if !enemy3.visible:
		enemy3.show()
