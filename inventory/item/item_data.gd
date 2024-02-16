extends Resource

class_name ItemData

@export var name : String
@export_multiline var description : String
@export var stackable : bool = false
@export var max_stack : int
@export var icon : Texture
@export var properties : Dictionary

func use(_target):
	pass
