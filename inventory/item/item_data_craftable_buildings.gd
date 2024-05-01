class_name ItemDataCraftableBuildings extends ItemData

enum BuildingType {
	floor = 0,
	wall = 1,
	roof = 2,
}

@export var item_type : ItemType = ItemType.building
@export var building_type : BuildingType
@export var craft_components : Array[CraftComponentData]
