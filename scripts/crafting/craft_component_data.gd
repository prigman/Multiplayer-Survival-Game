class_name CraftComponentData extends Resource

@export var component : ItemDataWorldResource
@export var amount : int = 1 : set = _set_amount

func _set_amount(value : int) -> void:
	amount = value
