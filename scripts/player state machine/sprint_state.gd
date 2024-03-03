class_name SprintState
extends PlayerMovementState

@export var speed_state = 7.0
	
func physics_update(delta):
	player.update_gravity(delta)
	player.update_input(speed_state, ACCELERATION, DECCELERATION)
	player.update_velocity()
	if Input.is_action_just_released("shift"):
		transition.emit("Walking")
	if player.is_on_floor():
		if Input.is_action_just_pressed("space"):
			transition.emit("Jump")
	else:
		if player.velocity.y < -3.0:
			transition.emit("Falling")
	
