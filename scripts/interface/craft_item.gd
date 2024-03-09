extends PanelContainer

const CRAFT_COMPONENT = preload("res://inventory/craft_menu_scenes/craft_item_component.tscn")

@onready var texture_rect = %TextureRect
@onready var craft_item_name = %CraftItemName
@onready var craft_item_button = %CraftItemButton
@onready var grid_container = %GridContainer

func set_craft_item_data(item_data : ItemDataCraftableWeapon):
	texture_rect.texture = item_data.icon
	craft_item_name.text = item_data.name
	for component_data in item_data.craft_components:
		if component_data:
			var craft_item_component = CRAFT_COMPONENT.instantiate()
			grid_container.add_child(craft_item_component)
			craft_item_component.texture_rect.texture = component_data.component.icon
			craft_item_component.amount.text = "x%s" % component_data.amount
			craft_item_component.craft_item_name.text = component_data.component.name
			
