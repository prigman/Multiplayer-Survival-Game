extends RigidBody3D

@export var slot_data : InSlotData

func _player_interact(inventory_data : InventoryData):
	if inventory_data._pick_up_slot_data(slot_data):
		queue_free()
	if slot_data.item.properties.has("equip_item"):
		var object = load(slot_data.item.properties["equip_item"])
		_instantiate_equiped_item(object)

func _instantiate_equiped_item(equiped_object : PackedScene):
	var obj = equiped_object.instantiate()
	#obj.slot_data = slot_data
	Global.global_player.items_holder.add_child(obj)
	obj.position = Vector3.ZERO
