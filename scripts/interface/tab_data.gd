class_name CraftMenuTabData extends Resource

enum TabType
{
	heal = 0,
	weapon = 1,
	buildings = 2,
	tools = 3
}

@export var icon : Texture
@export var type : TabType
@export var slot_in_tab : Array[InSlotData]
