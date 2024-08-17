class_name CraftMenuTabData extends Resource

enum TabType
{
	heal,
	weapon,
	building,
	tool
}

@export var icon : Texture
@export var type : TabType
@export var slot_in_tab : Array[InSlotData]
