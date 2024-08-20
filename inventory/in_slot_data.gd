extends Resource

class_name InSlotData

@export var item : ItemData
@export var amount_in_slot : int = 1 : set = _set_amount
var active_slot_data : bool

func _can_stack_with(other_slot_data : InSlotData) -> bool:
	return item.id == other_slot_data.item.id \
			and item.stackable \
			and amount_in_slot < item.max_stack

func _can_fully_stack_with(other_slot_data : InSlotData) -> bool:
	return item.id == other_slot_data.item.id \
			and item.stackable \
			and amount_in_slot + other_slot_data.amount_in_slot <= item.max_stack 

func _stack_with(other_slot_data : InSlotData) -> void:
	amount_in_slot += other_slot_data.amount_in_slot
	
func _create_single_slot_data() -> InSlotData:
	var new_slot_data := duplicate()
	new_slot_data.amount_in_slot = 1
	amount_in_slot -= 1
	return new_slot_data

func _set_amount(value : int) -> void:
	amount_in_slot = value
	if amount_in_slot > 1 and not item.stackable:
		amount_in_slot = 1
		push_error("%s is not stackable item" % item.name)


func serialize_data() -> Dictionary:
	return {
		"amount_in_slot": amount_in_slot,
	}