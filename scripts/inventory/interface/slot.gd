extends PanelContainer
class_name Slot

signal signal_slot_clicked(slot : Slot, button : int, peer_id : int)

@onready var texture_rect := %TextureRect
@onready var amount_text := %Amount
@onready var slot_number := %SlotNumber

# @export var rarity_regular_texture : PanelContainer
@export var rarity_unpopular_texture : PanelContainer
@export var rarity_rare_texture : PanelContainer
@export var rarity_top_texture : PanelContainer
@export var active_slot_panel : PanelContainer

@export var hover_panel : PanelContainer

var slot_rarity : Array

#var right_clicked : bool

func _ready() -> void:
	if rarity_unpopular_texture and rarity_rare_texture and rarity_top_texture:
		slot_rarity = [rarity_unpopular_texture, rarity_rare_texture, rarity_top_texture]

func _set_slot_data(slot_info: InSlotData) -> void:
	texture_rect.texture = slot_info.item.icon
	if slot_info.item and slot_rarity:
		for texture : CanvasItem in slot_rarity:
			if texture.visible: texture.hide()
		match slot_info.item.item_rarity:
			EnumData.ItemRarity.UNPOPULAR:
				rarity_unpopular_texture.show()
			EnumData.ItemRarity.RARE:
				rarity_rare_texture.show()
			EnumData.ItemRarity.TOP:
				rarity_top_texture.show()


	tooltip_text = "%s\n%s" % [slot_info.item.name, slot_info.item.description]
	
	if slot_info.amount_in_slot > 1:
		amount_text.text = "x%s" % slot_info.amount_in_slot
		amount_text.show()
	else:
		amount_text.hide()

func _on_gui_input(event : InputEvent) -> void:
	# if multiplayer.is_server(): return
	if event is InputEventMouseButton and event.is_pressed() \
		and (event.button_index == MOUSE_BUTTON_LEFT \
		or event.button_index == MOUSE_BUTTON_RIGHT):
		# player.rpc_id(1, "RPC_player_interacted_with_inventory", get_index(), event.button_index, multiplayer.get_unique_id(), slot_inventory_type)
		print("slot click from authority: ", multiplayer.get_unique_id())
		signal_slot_clicked.emit(get_index(), event.button_index, multiplayer.get_unique_id())

func _on_mouse_entered() -> void:
	if texture_rect.texture != null:
		if hover_panel:
			hover_panel.show()

func _on_mouse_exited() -> void:
	if hover_panel:
		if hover_panel.visible:
			hover_panel.hide()
