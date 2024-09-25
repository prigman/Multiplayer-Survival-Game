class_name ItemData1 extends Resource

enum ItemType {
	weapon,
	consumable,
	other,
	resource,
	tool ,
	building,
	ammo
}

enum WeaponType {
	assault_rifle,
	pistol,
	shotgun,
	revolver,
	rifle,
	submachine_gun,
	machine_gun
}

enum ItemRarity {
	regular,
	unpopular,
	rare,
	top
}

@export var id : int
@export var item_rarity : ItemRarity
@export var name: String
@export_multiline var description: String
@export_multiline var description_item_panel: String
@export var stackable: bool = false
@export var max_stack: int
@export var quality: float = 100
@export var icon: Texture

@export var dictionary: Dictionary


func serialize_item_data() -> Dictionary:
	return {
		"id": id,
		"quality": quality
	}

func deserialize_item_data(data: Dictionary) -> void:
	quality = data["quality"]