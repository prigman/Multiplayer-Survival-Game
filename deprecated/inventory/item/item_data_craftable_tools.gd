class_name ItemDataCraftableTools1 extends ItemDataTools1

@export var craft_components : Array[CraftComponentData]

func serialize_item_data() -> Dictionary:
	return {
		"quality": quality,
		"damage": damage
	}

func deserialize_item_data(data: Dictionary) -> void:
	quality = data["quality"]
	damage = data["damage"]