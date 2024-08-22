class_name WalkingState
extends PlayerMovementState

var speed_state : float
var walking_state := 5.0
	
func physics_update(delta : float) -> void:
	player.update_gravity(delta)
	if player.item.Scoped:
		speed_state = walking_state / 2
	else:
		speed_state = walking_state
	player.update_input(speed_state, ACCELERATION, DECCELERATION)
	player.update_velocity()
	if player.died:
		transition.emit("Death")
	if player.is_on_floor():
		if Input.is_action_pressed("left_ctrl"):
			transition.emit("Crouch")
		if Input.is_action_just_pressed("space"):
			transition.emit("Jump")
		if Input.is_action_pressed("shift"):
			transition.emit("Sprint")
	elif player.velocity.y < -3.0:
		transition.emit("Falling")
	if player.velocity.length() == 0:
		transition.emit("Idle")
