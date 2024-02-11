extends InventoryInterface

const SLOT_SCENE = preload("res://scenes/inventory/inventory_slot.tscn")

@onready var h_box_container = $MarginContainer/HBoxContainer

func _set_quick_slot_data(quick_slot_data : InventoryData):
	quick_slot_data.signal_inventory_update.connect(_set_quick_slots)
	_set_quick_slots(quick_slot_data)

func _set_quick_slots(inventory_data : InventoryData):
	for child in h_box_container.get_children():
		child.queue_free()
		
	for slot_data in inventory_data.slots_data:
		var slot = SLOT_SCENE.instantiate()
		h_box_container.add_child(slot)
		
		slot.signal_slot_clicked.connect(inventory_data._on_slot_clicked)
		if slot_data:
			slot._set_slot_data(slot_data)
