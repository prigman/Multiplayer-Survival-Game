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
		tab_data.TabType.buildings:
			set_current_page(buildings_page)
		tab_data.TabType.tools:
			set_current_page(tools_page)

func set_craftable_items(slots_in_tab : Array[InSlotData]):
	for slot_data in slots_in_tab:
		if slot_data:
			var craft_item = CRAFT_ITEM_SCENE.instantiate()
			item_weapon_container.add_child(craft_item)
			craft_item.set_craft_item_data(slot_data)
			craft_item.signal_craft_button_pressed.connect(_on_craft_button_pressed)
		
func set_current_page(page : ScrollContainer):
	if current_page:
		current_page.hide()
	if !page.visible:
		page.show()
		current_page = page
		page_name.text = "CRAFTING: %s" % page.name
		
func _on_craft_button_pressed(slot_data : InSlotData):
	var item_data = slot_data.item
	player_inventory_slots = Global.get_player_inventory_slots()
	player_quick_slots = Global.get_player_quick_slots()
	if player_inventory_slots and player_quick_slots:
		print("player_inventory_slots: %s" % player_inventory_slots.size())
		print("player_quick_slots: %s" % player_quick_slots.size())
		var components_available : int = 0
		var used_components := {}
		for inv_slot_data in player_inventory_slots:
			if inv_slot_data and inv_slot_data.item:
				for craft_item in item_data.craft_components:
					if craft_item and craft_item.component == inv_slot_data.item:
						var available = inv_slot_data.amount_in_slot - used_components.get(inv_slot_data.item, 0)
						if available >= craft_item.amount:
							print("able to craft with item: %s" % inv_slot_data.item.name)
							components_available += 1
							used_components[inv_slot_data.item] = used_components.get(inv_slot_data.item, 0) + craft_item.amount
						else:
							print("item available but not enough: %s" % inv_slot_data.item.name)
		for quick_slot in player_quick_slots:
			if quick_slot and quick_slot.item:
				for craft_item in item_data.craft_components:
					if craft_item and craft_item.component == quick_slot.item:
						var available = quick_slot.amount_in_slot - used_components.get(quick_slot.item, 0)
						if available >= craft_item.amount:
							print("from quick slots able to craft with item: %s" % quick_slot.item.name)
							components_available += 1
							used_components[quick_slot.item] = used_components.get(quick_slot.item, 0) + craft_item.amount
						else:
							print("from quick slots item available but not enough: %s" % quick_slot.item.name)
		# достаточно ли компонентов для крафта
		if components_available == item_data.craft_components.size():
			for craft_item in item_data.craft_components:
				var amount_used = used_components.get(craft_item.component, 0)
				# Обновление количества предметов в слотах
				for i in range(player_inventory_slots.size()):
					var inv_slot_data = player_inventory_slots[i]
					if inv_slot_data and inv_slot_data.item == craft_item.component:
						var available_in_slot = inv_slot_data.amount_in_slot
						var used_from_slot = min(available_in_slot, amount_used)
						inv_slot_data.amount_in_slot -= used_from_slot
						if inv_slot_data.amount_in_slot == 0:
							player_inventory_slots[i] = null  # Устанавливаем элемент массива в null
						amount_used -= used_from_slot

				for i in range(player_quick_slots.size()):
					var quick_slot = player_quick_slots[i]
					if quick_slot and quick_slot.item == craft_item.component:
						var available_in_slot = quick_slot.amount_in_slot
						var used_from_slot = min(available_in_slot, amount_used)
						quick_slot.amount_in_slot -= used_from_slot
						if quick_slot.amount_in_slot == 0:
							player_quick_slots[i] = null  # Устанавливаем элемент массива в null
						amount_used -= used_from_slot
			Global.global_player_inventory.signal_inventory_update.emit(Global.global_player_inventory)
			Global.global_player_quick_slot.signal_inventory_update.emit(Global.global_player_quick_slot)
			if !Global.global_player_inventory._pick_up_slot_data(slot_data.duplicate()):
				if !Global.global_player_quick_slot._pick_up_slot_data(slot_data.duplicate()):
					Global.global_player.inventory_interface.signal_drop_item.emit(slot_data.duplicate())
