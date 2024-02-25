extends Resource
class_name ItemData

enum ItemType {
	weapon = 0,
	consumable = 1,
	other = 2
}

@export var name : String
@export_multiline var description : String
@export var stackable : bool = false
@export var max_stack : int
@export var icon : Texture
@export var properties : Dictionary

