class_name AllGameInventoryItems extends Node

const DEFAULT_OBJECT := preload("res://scripts/inventory/item/resources/godot.tres")
const AMMO_AR := preload("res://scripts/inventory/item/resources/ammo/ammo_ar.tres")
const AXE := preload("res://scripts/inventory/item/resources/tool/axe.tres")
const BANDAGE := preload("res://scripts/inventory/item/resources/consumable/bandage.tres")
const CAN := preload("res://scripts/inventory/item/resources/consumable/can.tres")
const M4_RIFLE := preload("res://scripts/inventory/item/resources/firearm/m4_rifle.tres")
const PICKAXE := preload("res://scripts/inventory/item/resources/tool/pickaxe.tres")
const PINE_WOOD_CRATE := preload("res://scripts/inventory/item/resources/building/pine-wood-crate.tres")
const RESOURCE_BRANCH := preload("res://scripts/inventory/item/resources/world_resource/resource_branch.tres")
const RESOURCE_METAL_BAR := preload("res://scripts/inventory/item/resources/world_resource/resource_metal-bar.tres")
const RESOURCE_PINE_WOOD := preload("res://scripts/inventory/item/resources/world_resource/resource_pine_wood.tres")
const RESOURCE_STONE := preload("res://scripts/inventory/item/resources/world_resource/resource_stone.tres")
const WOODEN_FLOOR := preload("res://scripts/inventory/item/resources/building/wooden_floor.tres")
const WOODEN_ROOF := preload("res://scripts/inventory/item/resources/building/wooden_roof.tres")
const WOODEN_WALL := preload("res://scripts/inventory/item/resources/building/wooden_wall.tres")
const CAN_SMALL := preload("res://scripts/inventory/item/resources/consumable/can_small.tres")
const SODA_CAN := preload("res://scripts/inventory/item/resources/consumable/soda_can.tres")
const MEDKIT := preload("res://scripts/inventory/item/resources/consumable/medkit.tres")
const WOODEN_DOORWAY := preload("res://scripts/inventory/item/resources/building/wooden_doorway.tres")
const WOODEN_DOOR := preload("res://scripts/inventory/item/resources/building/wooden_door.tres")


static func load_item_data_by_id(id : int) -> Resource:
	match id:
		0:
			return DEFAULT_OBJECT
		1:
			return AMMO_AR
		2:
			return AXE
		3:
			return BANDAGE
		4:
			return CAN
		5:
			return M4_RIFLE
		6:
			return PICKAXE
		7:
			return PINE_WOOD_CRATE
		8:
			return RESOURCE_BRANCH
		9:
			return RESOURCE_METAL_BAR
		10:
			return RESOURCE_PINE_WOOD
		11:
			return RESOURCE_STONE
		12:
			return WOODEN_FLOOR
		13:
			return WOODEN_ROOF
		14:
			return WOODEN_WALL
		15:
			return CAN_SMALL
		16:
			return SODA_CAN
		17:
			return MEDKIT
		18:
			return WOODEN_DOORWAY
		19:
			return WOODEN_DOOR
		_:
			return DEFAULT_OBJECT

static func deserialize_slot_and_item_data(dict_slot_data : Dictionary, dict_item_data : Dictionary, item_id : int, inventory_data : InventoryNode = null) -> InSlotData:
	var item_data := load_item_data_by_id(item_id).duplicate(true)
	var new_slot_data : InSlotData
	if inventory_data:
		new_slot_data = inventory_data._create_new_slot(dict_slot_data["amount_in_slot"], item_data)
	else:
		new_slot_data = InSlotData.new()
		new_slot_data.item = item_data
		new_slot_data.amount_in_slot = dict_slot_data["amount_in_slot"]
	new_slot_data.item.deserialize_item_data(dict_item_data)
	return new_slot_data
