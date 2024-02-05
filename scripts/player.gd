class_name Player
extends CharacterBody3D

var lerp_speed = 20.0
var camera_holder_position
var input_dir = Vector2.ZERO
var direction = Vector3.ZERO

@export var mouse_sens = 0.15

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity = 12.0

@onready var spherecast = %ShapeCast3D
@onready var camera_holder = %CameraHolder
@onready var camera = %Camera3D


#var bullet_source = load("res://scenes/bullet.tscn")
#var instance
#@onready var weapon_anim = %AnimationPlayer
#@onready var weapon_muzzle = $CameraHolder/Weapons_Manager/ArmsHolder/Rifle/RayCast3D

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

func set_camera_fov(fov_value):
	camera.fov = lerp(camera.fov, fov_value, lerp_speed * velocity.length())

### States functions

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
