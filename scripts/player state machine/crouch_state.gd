class_name CrouchState
extends PlayerMovementState

const CROUCH_DEPTH = -0.5
var crouch_transition_time = 0.05

@export var speed_state = 3.0

@onready var spherecast = %ShapeCast3D
@onready var default_state_collision = %DefaultStateCollision
@onready var crouch_state_collision = %CrouchStateCollision

func physics_update(delta):
	player.update_gravity(delta)
	player.update_input(speed_state, ACCELERATION, DECCELERATION)
	player.update_velocity()
	player.camera_holder.position.y = player.camera_holder_position + CROUCH_DEPTH
	default_state_collision.disabled = true
	crouch_state_collision.disabled = false
	if Input.is_action_just_released("left_ctrl"):
		uncrouch(delta)
		
func uncrouch(delta):
	if !spherecast.is_colliding() and !Input.is_action_pressed("left_ctrl"):
		player.camera_holder.position.y = player.camera_holder_position
		default_state_collision.disabled = false
		crouch_state_collision.disabled = true
		transition.emit("Idle")
	elif spherecast.is_colliding():
		await get_tree().create_timer(0.1).timeout
		uncrouch(delta)
