class_name WalkingState
extends PlayerMovementState

@export var speed_state = 5.0
	
func physics_update(delta):
	player.update_gravity(delta)
	player.update_input(speed_state, ACCELERATION, DECCELERATION)
	player.update_velocity()
	if player.is_on_floor():
		if Input.is_action_pressed("left_ctrl"):
			transition.emit("Crouch")
		if Input.is_action_just_pressed("space"):
			transition.emit("Jump")
	
	if Input.is_action_pressed("shift"):
		transition.emit("Sprint")
	
	if player.velocity.length() <= 0:
		transition.emit("Idle")
