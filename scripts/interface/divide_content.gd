extends HBoxContainer

signal signal_divide_button_pressed(item_amount : int)

@onready var divide_button := %DivideButton
@onready var divide_scroll := %DivideScroll
@onready var divide_number := %DivideNumber

func _on_divide_scroll_scrolling() -> void:
	divide_number.text = str(divide_scroll.value)


func _on_divide_button_pressed() -> void:
	signal_divide_button_pressed.emit(divide_number.text.to_int())
