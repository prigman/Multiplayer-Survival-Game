class_name ItemDataWeapon extends ItemDataCraftable

@export var damage: float

func serialize_item_data() -> Dictionary:
	return {
		"quality": quality,
		"damage": damage,
	}

func deserialize_item_data(data: Dictionary) -> void:
	quality = data["quality"]
	damage = data["damage"]
