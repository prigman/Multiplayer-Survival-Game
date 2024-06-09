class_name ItemData extends Resource

enum ItemType {
	weapon,
	consumable,
	other,
	resource,
	tool ,
	building,
	ammo
}

enum WeaponType {
	assault_rifle,
	pistol,
	shotgun,
	revolver,
	rifle,
	submachine_gun,
	machine_gun
}

@export var name: String
@export_multiline var description: String
@export_multiline var description_item_panel: String
@export var stackable: bool = false
@export var max_stack: int
@export var quality: float = 100
@export var icon: Texture

@export var dictionary: Dictionary
