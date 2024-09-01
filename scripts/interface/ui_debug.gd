extends PanelContainer

var property : String
var fps_string : String

@export var player : Player

@onready var property_container := %VBoxContainer

func _process(delta : float) -> void:
	if multiplayer.get_unique_id() == player.peer_id:
		add_property("fps", fps_string, 0)
	if visible:
		fps_string = "%.f" % (1.0 / delta)

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("debug"):
		visible = !visible
		
func add_property(title : String, value : String, order : int) -> void:
	var target := property_container.find_child(title, true, false)
	if !target:
		target = Label.new()
		property_container.add_child(target)
		target.name = title
		target.text = target.name + ": " + str(value)
	elif visible:
		target.text = title + ": " + str(value)
		property_container.move_child(target, order)
