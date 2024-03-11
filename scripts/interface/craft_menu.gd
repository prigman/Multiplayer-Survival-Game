extends PanelContainer

const TAB_SCENE = preload("res://inventory/craft_menu_scenes/craft_menu_tab.tscn")
const CRAFT_ITEM_SCENE = preload("res://inventory/craft_menu_scenes/craft_item.tscn")

@onready var tab_container = %TabContainer

@onready var item_weapon_container = %ItemWeaponContainer
@onready var item_heal_container = %ItemHealContainer
@onready var item_buildings_container = %ItemBuildingsContainer
@onready var item_tools_container = %ItemToolsContainer

@onready var tools_page = %Tools
@onready var weapon_page = %Weapon
@onready var heal_page = %Heal
@onready var buildings_page = %Buildings
@onready var page_name = %PageName

@export var tabs_resource : CraftMenuTab

var player_inventory_slots : Array[InSlotData]
var player_quick_slots : Array[InSlotData]

var current_page = null

func _ready():
	if tabs_resource:
		set_craft_menu_tabs(tabs_resource)
		set_current_page(tools_page)
	else:
		push_error("Set tab_resource in node CraftMenu")

func set_craft_menu_tabs(craft_menu_tab : CraftMenuTab):
	for tab_data in craft_menu_tab.list:
		if tab_data:
			var tab = TAB_SCENE.instantiate()
			tab_container.add_child(tab)
			tab.set_tab_data(tab_data)
			tab.signal_tab_clicked.connect(_on_tab_clicked)
			set_craftable_items(tab_data.slot_in_tab)

func _on_tab_clicked(tab_data):
	match tab_data.type:
		tab_data.TabType.weapon:
			set_current_page(weapon_page)
		tab_data.TabType.heal:
			set_current_page(heal_page)
		tab_data.TabType.building:
			set_current_page(buildings_page)
		tab_data.TabType.tool:
			set_current_page(tools_page)

func set_craftable_items(slots_in_tab : Array[InSlotData]):
	for slot_data in slots_in_tab:
		var craft_item = CRAFT_ITEM_SCENE.instantiate()
		match slot_data.item.item_type:
			slot_data.item.ItemType.weapon:
				item_weapon_container.add_child(craft_item)
			slot_data.item.ItemType.consumable:
				item_heal_container.add_child(craft_item)
			slot_data.item.ItemType.building:
				item_buildings_container.add_child(craft_item)
			slot_data.item.ItemType.tool:
				item_tools_container.add_child(craft_item)
		craft_item.set_craft_item_data(slot_data)
		craft_item.signal_craft_button_pressed.connect(_on_craft_button_pressed)
		
func set_current_page(page : ScrollContainer):
	if current_page:
		current_page.hide()
	if !page.visible:
		page.show()
		current_page = page
		page_name.text = "CRAFTING: %s" % page.name
	
func _on_craft_button_pressed(slot_data: InSlotData):
	var item_data = slot_data.item
	player_inventory_slots = Global.get_player_inventory_slots()
	player_quick_slots = Global.get_player_quick_slots()
	if !player_inventory_slots or !player_quick_slots:
		return

	var used_components := {}
	var total_components_needed: int = item_data.craft_components.size()
	var total_components_used: int = 0
	for craft_item in item_data.craft_components:
		var component_found = false
		for slot in player_inventory_slots:
			if slot and slot.item and craft_item.component == slot.item:
				var available = slot.amount_in_slot - used_components.get(slot.item, 0)
				if available >= craft_item.amount:
					used_components[slot.item] = used_components.get(slot.item, 0) + craft_item.amount
					total_components_used += craft_item.amount
					component_found = true
					break

		if !component_found:
			for slot in player_quick_slots:
				if slot and slot.item and craft_item.component == slot.item:
					var available = slot.amount_in_slot - used_components.get(slot.item, 0)
					if available >= craft_item.amount:
						used_components[slot.item] = used_components.get(slot.item, 0) + craft_item.amount
						total_components_used += craft_item.amount
						break

	# достаточно ли компонентов для крафта
	if total_components_used >= total_components_needed:
		for craft_item in item_data.craft_components:
			var amount_used = used_components.get(craft_item.component, 0)
			for slot in player_inventory_slots:
				if slot and slot.item == craft_item.component:
					var available_in_slot = slot.amount_in_slot
					var used_from_slot = min(available_in_slot, amount_used)
					slot.amount_in_slot -= used_from_slot
					amount_used -= used_from_slot

			for slot in player_quick_slots:
				if slot and slot.item == craft_item.component:
					var available_in_slot = slot.amount_in_slot
					var used_from_slot = min(available_in_slot, amount_used)
					slot.amount_in_slot -= used_from_slot
					amount_used -= used_from_slot

		Global.global_player_inventory.signal_inventory_update.emit(Global.global_player_inventory)
		Global.global_player_quick_slot.signal_inventory_update.emit(Global.global_player_quick_slot)

		if !Global.global_player_inventory._pick_up_slot_data(slot_data.duplicate()) \
				and !Global.global_player_quick_slot._pick_up_slot_data(slot_data.duplicate()):
			Global.global_player.inventory_interface.signal_drop_item.emit(slot_data.duplicate())

		Global.global_player_inventory.signal_inventory_update.emit(Global.global_player_inventory)
		Global.global_player_quick_slot.signal_inventory_update.emit(Global.global_player_quick_slot)

		if !Global.global_player_inventory._pick_up_slot_data(slot_data.duplicate()) \
				and !Global.global_player_quick_slot._pick_up_slot_data(slot_data.duplicate()):
			Global.global_player.inventory_interface.signal_drop_item.emit(slot_data.duplicate())
