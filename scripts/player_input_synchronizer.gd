extends MultiplayerSynchronizer

@export var input_direction := Vector2()
@export var mouse_sens = 0.15
@export var player : Player

var mouse_input: Vector2

@onready var camera_holder = %CameraHolder
@onready var camera = %Camera3D
@onready var inventory_interface = %InventoryInterface



func _ready():
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		camera.make_current()
	else:
		set_process(false)
		set_process_input(false)
		camera.clear_current(false)

func _process(_delta):
	input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

func _input(event):
	if event is InputEventMouseMotion and !inventory_interface.visible:
		player.rotate_y(deg_to_rad( - event.relative.x * mouse_sens))
		camera_holder.rotate_x(deg_to_rad( - event.relative.y * mouse_sens))
		camera_holder.rotation.x = clamp(camera_holder.rotation.x, deg_to_rad( - 85), deg_to_rad(85))
		mouse_input = event.relative
