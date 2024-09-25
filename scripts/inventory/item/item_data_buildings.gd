extends ItemDataCraftable
class_name ItemDataBuildings

enum BuildingType {
	floor,
	wall,
	roof,
	inventory,
	door,
}

@export var building_type : BuildingType
