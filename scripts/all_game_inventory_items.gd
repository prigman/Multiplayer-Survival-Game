class_name AllGameInventoryItems extends Node

# const DEFAULT_OBJECT := preload("res://inventory/item/objects/godot.tres")
# const AMMO_AR := preload("res://inventory/item/objects/ammo/ammo_ar.tres")
# const AXE := preload("res://inventory/item/objects/axe.tres")
# const BANDAGE := preload("res://inventory/item/objects/bandage.tres")
# const CAN := preload("res://inventory/item/objects/can.tres")
# const M4_RIFLE := preload("res://inventory/item/objects/m4_rifle.tres")
# const PICKAXE := preload("res://inventory/item/objects/pickaxe.tres")
# const PINE_WOOD_CRATE := preload("res://inventory/item/objects/pine-wood-crate.tres")
# const RESOURCE_BRANCH := preload("res://inventory/item/objects/resource_branch.tres")
# const RESOURCE_METAL_BAR := preload("res://inventory/item/objects/resource_metal-bar.tres")
# const RESOURCE_PINE_WOOD := preload("res://inventory/item/objects/resource_pine_wood.tres")
# const RESOURCE_STONE := preload("res://inventory/item/objects/resource_stone.tres")
# const WOODEN_FLOOR := preload("res://inventory/item/objects/wooden_floor.tres")
# const WOODEN_ROOF := preload("res://inventory/item/objects/wooden_roof.tres")
# const WOODEN_WALL := preload("res://inventory/item/objects/wooden_wall.tres")
# const CAN_SMALL := preload("res://inventory/item/objects/can_small.tres")
# const SODA_CAN := preload("res://inventory/item/objects/soda_can.tres")
# const MEDKIT := preload("res://inventory/item/objects/medkit.tres")
# const WOODEN_DOORWAY := preload("res://inventory/item/objects/wooden_doorway.tres")
# const WOODEN_DOOR := preload("res://inventory/item/objects/wooden_door.tres")


# static func load_item_data_by_id(id : int) -> Resource:
# 	match id:
# 		0:
# 			return DEFAULT_OBJECT
# 		1:
# 			return AMMO_AR
# 		2:
# 			return AXE
# 		3:
# 			return BANDAGE
# 		4:
# 			return CAN
# 		5:
# 			return M4_RIFLE
# 		6:
# 			return PICKAXE
# 		7:
# 			return PINE_WOOD_CRATE
# 		8:
# 			return RESOURCE_BRANCH
# 		9:
# 			return RESOURCE_METAL_BAR
# 		10:
# 			return RESOURCE_PINE_WOOD
# 		11:
# 			return RESOURCE_STONE
# 		12:
# 			return WOODEN_FLOOR
# 		13:
# 			return WOODEN_ROOF
# 		14:
# 			return WOODEN_WALL
# 		15:
# 			return CAN_SMALL
# 		16:
# 			return SODA_CAN
# 		17:
# 			return MEDKIT
# 		18:
# 			return WOODEN_DOORWAY
# 		19:
# 			return WOODEN_DOOR
# 		_:
# 			return DEFAULT_OBJECT

# static func deserialize_slot_and_item_data(dict_slot_data : Dictionary, dict_item_data : Dictionary, item_id : int, inventory_data : InventoryData = null) -> InSlotData:
# 	var item_data := load_item_data_by_id(item_id).duplicate(true)
# 	var new_slot_data : InSlotData
# 	if inventory_data:
# 		new_slot_data = inventory_data._create_new_slot(dict_slot_data["amount_in_slot"], item_data)
# 	else:
# 		new_slot_data = InSlotData.new()
# 		new_slot_data.item = item_data
# 		new_slot_data.amount_in_slot = dict_slot_data["amount_in_slot"]
# 	new_slot_data.item.deserialize_item_data(dict_item_data)
# 	return new_slot_data
