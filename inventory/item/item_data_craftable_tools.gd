class_name ItemDataCraftableTools extends ItemDataTools

@export var craft_components : Array[CraftComponentData]

func serialize_item_data() -> Dictionary:
	return {
		"quality": quality,
		"damage": damage
	}

static func deserialize_item_data(data: Dictionary) -> ItemDataCraftableTools:
	var item_data = ItemDataCraftableTools.new()
	item_data.quality = data["quality"]
	item_data.damage = data["damage"]
	return item_data