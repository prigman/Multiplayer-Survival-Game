class_name CraftComponentData extends Resource

@export var component : ItemDataResource
@export var amount : int = 1 : set = _set_amount

func _set_amount(value : int):
	amount = value
