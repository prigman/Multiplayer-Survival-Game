extends MultiplayerSynchronizer

@export var input_direction := Vector2()

@onready var camera = %Camera3D




func _ready():
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		camera.make_current()
	else:
		set_process(false)
		set_process_input(false)
		camera.clear_current(false)

func _process(_delta):
	input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
