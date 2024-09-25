class_name ItemDataCraftableBuildings1 extends ItemData1

enum BuildingType {
	floor,
	wall,
	roof,
	inventory,
	door,
}

@export var item_type : ItemType = ItemType.building
@export var building_type : BuildingType
@export var craft_components : Array[CraftComponentData]
