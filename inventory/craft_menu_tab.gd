extends PanelContainer

signal signal_tab_clicked(index : int)

@onready var texture_rect := %TextureRect

var tab_data : CraftMenuTabData

func set_tab_data(craft_menu_tab_data : CraftMenuTabData) -> void:
	texture_rect.texture = craft_menu_tab_data.icon
	tab_data = craft_menu_tab_data

func _on_gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() \
		and (event.button_index == MOUSE_BUTTON_LEFT \
		or event.button_index == MOUSE_BUTTON_RIGHT):
		signal_tab_clicked.emit(tab_data)
