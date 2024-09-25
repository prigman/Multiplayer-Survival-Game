extends PanelContainer

@onready var item_health := %ItemHealth
@onready var item_icon := %ItemIcon
@onready var ammo_count_panel := %AmmoCountPanel
@onready var ammo_count := %AmmoCount
@onready var item_name := %ItemName
@onready var item_description := %ItemDescription
@onready var weapon_slots := %WeaponSlots
@onready var item_use_button := %ItemUseButton
@onready var weapon_unload_button := %WeaponUnloadButton
@onready var item_drop_button := %ItemDropButton
@onready var divide_content := %DivideContent
@onready var rarity := %Rarity

func _on_inventory_interface_signal_item_info_panel_set_data(item_data : ItemData, slot_data : InSlotData) -> void:
	item_icon.texture = item_data.icon
	item_name.text = item_data.name
	item_description.text = item_data.description_item_panel
	item_health.value = item_data.quality
	var rarity_name : String
	match item_data.item_rarity:
		EnumData.ItemRarity.REGULAR:
			rarity_name = "regular"
			# color_hex = item_data.item_rarity_colors[0]
			rarity.modulate = Color(1, 1, 1) 
		EnumData.ItemRarity.UNPOPULAR:
			rarity_name = "unpopular"
			# color_hex = item_data.item_rarity_colors[1]
			rarity.modulate = Color(0.263, 0.812, 0.929)
		EnumData.ItemRarity.RARE:
			rarity_name = "rare"
			# color_hex = item_data.item_rarity_colors[2]
			rarity.modulate = Color(0.231, 0.431, 0.922)
		EnumData.ItemRarity.TOP:
			rarity_name = "top"
			# color_hex = item_data.item_rarity_colors[3]
			rarity.modulate = Color(0.794, 0.342, 0.929)
	rarity.text = rarity_name
	if slot_data.amount_in_slot > 1:
		custom_minimum_size.y = 200
		divide_content.divide_scroll.max_value = slot_data.amount_in_slot - 1
		divide_content.divide_scroll.min_value = 1
		divide_content.divide_scroll.page = min(divide_content.divide_scroll.min_value, divide_content.divide_scroll.max_value)
		divide_content.divide_scroll.value = slot_data.amount_in_slot / 2
		divide_content.divide_number.text = str(divide_content.divide_scroll.value)
		divide_content.show()
	else:
		if divide_content.visible:
			custom_minimum_size.y = 180
			divide_content.hide()
	if !item_health.visible:
		item_health.show()
	if item_data.item_type == EnumData.ItemType.FIREARM:
		ammo_count.text = "%s" % item_data.ammo_current
		if !ammo_count_panel.visible:
			ammo_count_panel.show()
		if !weapon_slots.visible:
			weapon_slots.show()
		if item_use_button.visible:
			item_use_button.hide()
		if !weapon_unload_button.visible:
			weapon_unload_button.show()
	else:
		if item_use_button.visible:
			item_use_button.hide()
		if ammo_count_panel.visible:
			ammo_count_panel.hide()
		if weapon_slots.visible:
			weapon_slots.hide()
		if weapon_unload_button.visible:
			weapon_unload_button.hide()
		if item_data.item_type == EnumData.ItemType.WORLD_RESOURCE:
			if item_health.visible:
				item_health.hide()
		if item_data.item_type == EnumData.ItemType.CONSUMABLE:
			if !item_health.visible:
				item_health.show()
			item_use_button.show()
