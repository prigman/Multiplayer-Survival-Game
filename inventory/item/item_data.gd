extends Resource
class_name ItemData

enum ItemType {
	weapon = 0,
	consumable = 1,
	other = 2
}

@export var name : String
@export_multiline var description : String
@export_multiline var description_item_panel : String
@export var stackable : bool = false
@export var max_stack : int
@export var quality : float = 100
@export var icon : Texture
@export var mesh : Mesh

@export var dictionary : Dictionary
@export var position : Vector3
@export var rotation : Vector3
@export var scale : Vector3

