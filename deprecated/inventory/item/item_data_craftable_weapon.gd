class_name ItemDataCraftableWeapon1 extends ItemDataWeapon1

@export var craft_components : Array[CraftComponentData]


func serialize_item_data() -> Dictionary:
	return {
		"quality": quality,
		"damage": damage,
		"ammo_current": ammo_current
	}

func deserialize_item_data(data: Dictionary) -> void:
	quality = data["quality"]
	damage = data["damage"]
	ammo_current = data["ammo_current"]