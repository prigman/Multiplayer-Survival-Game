extends RigidBody3D

@export var slot_data : InSlotData

func _player_interact(inventory_data : InventoryData):
	if inventory_data._pick_up_slot_data(slot_data):
		queue_free()
