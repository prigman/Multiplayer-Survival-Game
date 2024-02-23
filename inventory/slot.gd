extends PanelContainer
class_name Slot
signal signal_slot_clicked(index : int, button : int)

var mouse_button_hold : bool
@onready var texture_rect = $MarginContainer/TextureRect
@onready var amount_text = $"Quantity label"
@onready var panel_container = $PanelContainer

func _set_slot_data(slot_info: InSlotData):
	texture_rect.texture = slot_info.item.icon
	tooltip_text = "%s\n%s" % [slot_info.item.name, slot_info.item.description]
	
	if slot_info.amount_in_slot > 1:
		amount_text.text = "x%s" % slot_info.amount_in_slot
		amount_text.show() 
	else:
		amount_text.hide()
	
func _on_gui_input(event : InputEvent):
	if event is InputEventMouseButton \
			and (event.button_index == MOUSE_BUTTON_LEFT \
			or event.button_index == MOUSE_BUTTON_RIGHT) \
			and event.is_pressed():
			signal_slot_clicked.emit(get_index(), event.button_index)
