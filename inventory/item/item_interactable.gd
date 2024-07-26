extends RigidBody3D

@export var slot_data : InSlotData

@rpc("any_peer")
func request_free():
		queue_free()

func _player_interact(inventory_data : InventoryData, quick_slot_data : InventoryData):
	if !inventory_data._pick_up_slot_data(slot_data):
		if quick_slot_data._pick_up_slot_data(slot_data):
			rpc('request_free')
		else:
			print("Inventories are full")
	else:
		queue_free()
