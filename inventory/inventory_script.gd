extends PanelContainer

const SLOT_SCENE = preload("res://inventory/inventory_scenes/inventory_slot.tscn")
@onready var grid_container = $MarginContainer/GridContainer

func _set_inventory_data(inventory_data : InventoryData):
	inventory_data.signal_inventory_update.connect(_set_inventory_slots)
	_set_inventory_slots(inventory_data)
	
func _clear_inventory_data(inventory_data : InventoryData):
	inventory_data.signal_inventory_update.disconnect(_set_inventory_slots)

func _set_inventory_slots(inventory_data : InventoryData):
	for child in grid_container.get_children():
		child.queue_free()
		
	for slot_data in inventory_data.slots_data:
		var slot = SLOT_SCENE.instantiate()
		grid_container.add_child(slot)
		
		slot.signal_slot_clicked.connect(inventory_data._on_slot_clicked)
		
		if slot_data:
			slot._set_slot_data(slot_data)
