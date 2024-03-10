extends PanelContainer
class_name Slot

signal signal_slot_clicked(index : int, button : int)

@onready var texture_rect = %TextureRect
@onready var amount_text = %Amount
@onready var active_slot_panel = %ActiveSlotPanel
@onready var slot_number = %SlotNumber

@export var hover_panel : PanelContainer

#var right_clicked : bool

func _set_slot_data(slot_info: InSlotData):
	texture_rect.texture = slot_info.item.icon
	tooltip_text = "%s\n%s" % [slot_info.item.name, slot_info.item.description]
	
	if slot_info.amount_in_slot > 1:
		amount_text.text = "x%s" % slot_info.amount_in_slot
		amount_text.show()
	else:
		amount_text.hide()

func _on_gui_input(event : InputEvent):
	if event is InputEventMouseButton and event.is_pressed() \
		and (event.button_index == MOUSE_BUTTON_LEFT \
		or event.button_index == MOUSE_BUTTON_RIGHT):
		signal_slot_clicked.emit(get_index(), event.button_index)

func _on_mouse_entered():
	if texture_rect.texture != null:
		if hover_panel:
			hover_panel.show()

func _on_mouse_exited():
	if hover_panel:
		if hover_panel.visible:
			hover_panel.hide()
