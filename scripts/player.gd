class_name Player
extends CharacterBody3D

signal signal_toggle_inventory()

var camera_holder_position
var input_dir = Vector2.ZERO
var direction = Vector3.ZERO
var gravity = 12.0

@export var mouse_sens = 0.15

@export var player_inventory : InventoryData
@export var player_quick_slot : InventoryData

#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var spherecast = %ShapeCast3D
@onready var camera_holder = %CameraHolder
@onready var camera = %Camera3D
@onready var interact_ray = $CameraHolder/Camera3D/InteractRay
@onready var items_holder = $CameraHolder/ArmsHolder/ItemsHolder


func _ready():
	Global.global_player = self
	camera_holder_position = camera_holder.position.y
	spherecast.add_exception($".")

func _process(_delta):
	var velocity_string = "%.2f" % velocity.length()
	Global.global_debug.add_property("velocity", velocity_string, +1)
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		camera_holder.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		camera_holder.rotation.x = clamp(camera_holder.rotation.x, deg_to_rad(-85), deg_to_rad(85))

func _unhandled_input(_event):
	if Input.is_action_just_pressed("inv_toggle"):
		signal_toggle_inventory.emit()
	if Input.is_action_just_pressed("interact"):
		interact()

### Player states

func update_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
func update_input(speed, acceleration, decceleration):
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	direction = transform.basis * Vector3(input_dir.x, 0, input_dir.y).normalized()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, decceleration)
		velocity.z = move_toward(velocity.z, 0, decceleration)
	
func update_velocity():
	move_and_slide()

func interact():
	if interact_ray.is_colliding():
		interact_ray.get_collider()._player_interact(player_inventory)

func get_drop_position() -> Vector3:
	var drop_direction = -camera.global_transform.basis.z
	return camera.global_position + drop_direction
