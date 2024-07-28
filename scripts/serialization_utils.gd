extends Node


func serialize_in_slot_data(slot_data: InSlotData) -> Dictionary:
    return slot_data.serialize()

func deserialize_in_slot_data(data: Dictionary) -> InSlotData:
    return InSlotData.deserialize(data)