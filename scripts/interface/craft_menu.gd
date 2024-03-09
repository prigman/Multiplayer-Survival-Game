extends PanelContainer

const TAB_SCENE = preload("res://inventory/craft_menu_scenes/craft_menu_tab.tscn")
const CRAFT_ITEM_SCENE = preload("res://inventory/craft_menu_scenes/craft_item.tscn")

@onready var tab_container = %TabContainer
@onready var tab_container_2 = %TabContainer2

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

@export var all_craftable_items : AllCraftableItems

var current_page = null

func _ready():
	if tabs_resource or all_craftable_items:
		set_craft_menu_tabs(tabs_resource)
		set_craftable_items(all_craftable_items)
		set_current_page(tools_page)
	else:
		push_error("Set resources in node CraftMenu")

func set_craft_menu_tabs(craft_menu_tab : CraftMenuTab):
	for tab_data in craft_menu_tab.list:
		var tab = TAB_SCENE.instantiate()
		tab_container_2.add_child(tab)
		tab.set_tab_data(tab_data)
		tab.signal_tab_clicked.connect(_on_tab_clicked)
		
func _on_tab_clicked(tab_data):
	if tab_data.type == tab_data.TabType.weapon:
		set_current_page(weapon_page)
	if tab_data.type == tab_data.TabType.heal:
		set_current_page(heal_page)
	if tab_data.type == tab_data.TabType.buildings:
		set_current_page(buildings_page)
	if tab_data.type == tab_data.TabType.tools:
		set_current_page(tools_page)

func set_craftable_items(craftable_items : AllCraftableItems):
	for weapon in craftable_items.weapons:
		var craft_item = CRAFT_ITEM_SCENE.instantiate()
		item_weapon_container.add_child(craft_item)
		craft_item.set_craft_item_data(weapon)
		
func set_current_page(page : ScrollContainer):
	if current_page:
		current_page.hide()
	if !page.visible:
		page.show()
		current_page = page
		page_name.text = "CRAFTING: %s" % page.name
