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


func serialize() -> Dictionary:
	return {
		"name": name,
		"description": description,
		"description_item_panel": description_item_panel,
		"stackable": stackable,
		"max_stack": max_stack,
		"quality": quality,
		"icon": icon.resource_path, # передаем путь к текстуре, так как сами текстуры не передаются через RPC
		"dictionary": dictionary
	}

static func deserialize(data: Dictionary) -> ItemData:
	var item_data = ItemData.new()
	item_data.name = data["name"]
	item_data.description = data["description"]
	item_data.description_item_panel = data["description_item_panel"]
	item_data.stackable = data["stackable"]
	item_data.max_stack = data["max_stack"]
	item_data.quality = data["quality"]
	item_data.icon = load(data["icon"]) # загружаем текстуру из пути
	item_data.dictionary = data["dictionary"]
	return item_data
