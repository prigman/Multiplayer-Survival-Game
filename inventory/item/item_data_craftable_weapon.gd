class_name ItemDataCraftableWeapon extends ItemDataWeapon

@export var craft_components : Array[CraftComponentData]


func serialize_item_data() -> Dictionary:
	return {
		"quality": quality,
		"damage": damage,
		"ammo_current": ammo_current
	}

static func deserialize_item_data(data: Dictionary) -> ItemDataCraftableWeapon:
	var item_data = ItemDataCraftableWeapon.new()
	item_data.quality = data["quality"]
	item_data.damage = data["damage"]
	return item_data