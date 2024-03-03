extends PanelContainer

var property
var fps_string : String

@onready var property_container = %VBoxContainer

func _ready():
	Global.global_debug = self

func _process(delta):
	add_property("fps", fps_string, 0)
	if visible:
		fps_string = "%.f" % (1.0 / delta)

func _input(event):
	if event.is_action_pressed("debug"):
		visible = !visible
		
func add_property(title : String, value, order):
	var target
	target = property_container.find_child(title, true, false)
	if !target:
		target = Label.new()
		property_container.add_child(target)
		target.name = title
		target.text = target.name + ": " + str(value)
	elif visible:
		target.text = title + ": " + str(value)
		property_container.move_child(target, order)
