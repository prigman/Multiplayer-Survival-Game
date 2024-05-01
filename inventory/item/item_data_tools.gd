class_name ItemDataTools extends ItemData

enum ToolType {
	pickaxe = 0,
	axe = 1
}

@export var item_type : ItemType = ItemType.tool
@export var tool_type : ToolType
@export var anim_hit : String
@export var anim_after_hit : String
@export var damage : int
