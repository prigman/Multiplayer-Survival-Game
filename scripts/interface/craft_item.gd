extends PanelContainer

signal signal_craft_button_pressed(index : int)

# const CRAFT_COMPONENT := preload("res://inventory/craft_menu_scenes/craft_item_component.tscn")

@onready var texture_rect := %TextureRect
@onready var craft_item_name := %CraftItemName
@onready var craft_item_button := %CraftItemButton
@onready var grid_container := %GridContainer

var slot : InSlotData

# func set_craft_item_data(slot_data : InSlotData) -> void:
# 	var item_data := slot_data.item
# 	texture_rect.texture = item_data.icon
# 	craft_item_name.text = item_data.name
# 	slot = slot_data
# 	for craft_item : CraftComponentData in item_data.craft_components:
# 		if craft_item:
# 			var craft_item_component := CRAFT_COMPONENT.instantiate()
# 			grid_container.add_child(craft_item_component)
# 			craft_item_component.texture_rect.texture = craft_item.component.icon
# 			craft_item_component.amount.text = "x%s" % craft_item.amount
# 			craft_item_component.tooltip_text = "%s\n%s" % [craft_item.component.name, craft_item.component.description]
# 			craft_item_component.craft_item_name.text = craft_item.component.name

func _on_craft_item_button_pressed() -> void:
	signal_craft_button_pressed.emit(slot)
