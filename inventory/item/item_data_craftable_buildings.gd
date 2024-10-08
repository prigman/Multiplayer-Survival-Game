class_name ItemDataCraftableBuildings extends ItemData

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
