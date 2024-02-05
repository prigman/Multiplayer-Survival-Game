extends Node

@onready var player = $Player
# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if(player.position.y <= -10.0):
		get_tree().reload_current_scene()
	
