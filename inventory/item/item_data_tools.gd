class_name ItemDataTools extends ItemData

enum ToolType {
	pickaxe,
	axe
}

@export var item_type: ItemType = ItemType. tool
@export var tool_type: ToolType
@export var anim_activate: String
@export var anim_hit: String
@export var anim_after_hit: String
@export var anim_player_activate: String
@export var anim_player_hit: String
@export var anim_player_after_hit: String
@export var damage: int

func serialize_item_data() -> Dictionary:
	return {
		"quality": quality,
		"damage": damage
	}

func deserialize_item_data(data: Dictionary) -> void:
	quality = data["quality"]
	damage = data["damage"]