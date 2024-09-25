extends ItemDataCraftable
class_name ItemDataConsumable

@export var health_value: float
@export var hunger_value: float 

func serialize_item_data() -> Dictionary:
	return {
		"id": id,
		"quality": quality
	}

func deserialize_item_data(data: Dictionary) -> void:
	quality = data["quality"]