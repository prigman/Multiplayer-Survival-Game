extends Area3D

enum ColliderType {
	floor,
	wall,
	roof,
	other,
}

@export var collider_type : ColliderType
@export var item_data : ItemDataCraftableBuildings 

var is_able_to_place : bool = false