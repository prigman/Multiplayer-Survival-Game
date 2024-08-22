extends MultiplayerSynchronizer

@export var input_direction := Vector2()
@export var mouse_sens := 0.15
@export var player : CharacterBody3D

@onready var item := %Item
@onready var camera := %Camera3D
@onready var camera_holder := %CameraHolder
@onready var inventory_interface := %InventoryInterface

var mouse_input : Vector2

func _ready() -> void:
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		camera.make_current()
	else:
		set_process_for_player(false)

func set_process_for_player(value : bool) -> void:
	player.set_process_input(value)
	player.set_process_unhandled_input(value)
	player.set_physics_process(value)
	player.set_process(value)
	item.set_physics_process(value)
	item.set_process(value)
	item.set_process_unhandled_input(value)
	item.set_process_input(value)
	set_process(value)
	set_process_input(value)
	set_process_unhandled_input(value)

func _process(_delta : float) -> void:
	input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion and !player.is_inventory_open():
		player.rotate_y(deg_to_rad( - event.relative.x * mouse_sens))
		camera_holder.rotate_x(deg_to_rad( - event.relative.y * mouse_sens))
		camera_holder.rotation.x = clamp(camera_holder.rotation.x, deg_to_rad( - 85), deg_to_rad(85))
		mouse_input = event.relative

func _unhandled_input(event : InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		# get_tree().quit()
		player.signal_toggle_inventory.emit()
	if event.is_action_pressed("inv_toggle"):
		player.signal_toggle_inventory.emit()
	if event.is_action_pressed("interact"):
		player.interact()
