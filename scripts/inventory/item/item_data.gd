class_name ItemData extends Resource

@export var id : int
@export var item_type : EnumData.ItemType
@export var item_rarity : EnumData.ItemRarity
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
