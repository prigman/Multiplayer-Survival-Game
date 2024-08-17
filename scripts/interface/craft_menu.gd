extends PanelContainer

const TAB_SCENE = preload("res://inventory/craft_menu_scenes/craft_menu_tab.tscn")
const CRAFT_ITEM_SCENE = preload("res://inventory/craft_menu_scenes/craft_item.tscn")

@onready var tab_container := %TabContainer

@onready var item_weapon_container := %ItemWeaponContainer
@onready var item_heal_container := %ItemHealContainer
@onready var item_buildings_container := %ItemBuildingsContainer
@onready var item_tools_container := %ItemToolsContainer

@onready var tools_page := %Tools
@onready var weapon_page := %Weapon
@onready var heal_page := %Heal
@onready var buildings_page := %Buildings
@onready var page_name := %PageName

@export var tabs_resource : CraftMenuTab
@export var player: CharacterBody3D

var current_page: ScrollContainer

func _ready() -> void:
	if tabs_resource:
		set_craft_menu_tabs(tabs_resource)
		set_current_page(tools_page)
	else:
		push_error("Set tab_resource in node CraftMenu")

func set_craft_menu_tabs(craft_menu_tab : CraftMenuTab) -> void:
	for tab_data in craft_menu_tab.list:
		if tab_data:
			var tab = TAB_SCENE.instantiate()
			tab_container.add_child(tab)
			tab.set_tab_data(tab_data)
			tab.signal_tab_clicked.connect(_on_tab_clicked)
			set_craftable_items(tab_data.slot_in_tab)

func _on_tab_clicked(tab_data) -> void:
	match tab_data.type:
		tab_data.TabType.weapon:
			set_current_page(weapon_page)
		tab_data.TabType.heal:
			set_current_page(heal_page)
		tab_data.TabType.building:
			set_current_page(buildings_page)
		tab_data.TabType.tool:
			set_current_page(tools_page)

func set_craftable_items(slots_in_tab : Array[InSlotData]) -> void:
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
		
func set_current_page(page : ScrollContainer) -> void:
	if current_page:
		current_page.hide()
	if !page.visible:
		page.show()
		current_page = page
		page_name.text = "CRAFTING: %s" % page.name
	
func _on_craft_button_pressed(slot_data: InSlotData) -> void:
	var item_data = slot_data.item
	var craft_possible = true
	var player_inventory_slots = player.player_inventory.slots_data
	var player_quick_slots = player.player_quick_slot.slots_data
	if !player_inventory_slots or !player_quick_slots:
		return
	# Проверяем, есть ли у игрока все необходимые компоненты для крафта
	for craft_item in item_data.craft_components:
		var required_amount = craft_item.amount
		var found_amount = 0
	# Проверяем инвентарь игрока на наличие необходимого компонента
		for slot in player_inventory_slots:
			if slot and slot.item == craft_item.component:
				found_amount += slot.amount_in_slot
		# Проверяем быстрые слоты игрока на наличие необходимого компонента
		for slot in player_quick_slots:
			if slot and slot.item == craft_item.component:
				found_amount += slot.amount_in_slot
		# Если игрок не имеет достаточное количество компонента для крафта
		if found_amount < required_amount:
			craft_possible = false
			break
	# Если крафт возможен
	if craft_possible:
		# Уменьшаем количество необходимых компонентов в инвентаре игрока
		for craft_item in item_data.craft_components:
			var required_amount = craft_item.amount
			var remaining_amount = required_amount
			# Уменьшаем количество компонентов в инвентаре
			for slot in player_inventory_slots:
				if slot and slot.item == craft_item.component:
					if slot.amount_in_slot <= remaining_amount:
						remaining_amount -= slot.amount_in_slot
						slot.amount_in_slot = 0
					else:
						slot.amount_in_slot -= remaining_amount
						remaining_amount = 0
					if remaining_amount == 0:
						break
			# Уменьшаем количество компонентов в быстрых слотах
			for slot in player_quick_slots:
				if slot and slot.item == craft_item.component:
					if slot.amount_in_slot <= remaining_amount:
						remaining_amount -= slot.amount_in_slot
						slot.amount_in_slot = 0
					else:
						slot.amount_in_slot -= remaining_amount
						remaining_amount = 0
					if remaining_amount == 0:
						break
		player.give_item(slot_data.duplicate(true))
	else:
		print("Not enough components for crafting.")
