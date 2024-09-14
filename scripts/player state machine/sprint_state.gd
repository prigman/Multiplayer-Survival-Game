class_name SprintState
extends PlayerMovementState

@export var speed_state := 7.0

func physics_update(delta : float) -> void:
	# if multiplayer.get_unique_id() == player.peer_id:
	# 	player.input_sync.update_gravity(delta)
	# 	player.input_sync.update_input(speed_state, ACCELERATION, DECCELERATION)
	# 	player.input_sync.update_velocity()
	# else:
	player.update_gravity(delta)
	player.update_input(speed_state, ACCELERATION, DECCELERATION)
	player.update_velocity()
	if player.died and multiplayer.is_server():
		transition.emit("Death")
	if player.is_on_floor():
		if player.space_button_pressed and multiplayer.is_server():
			transition.emit("Jump")
		if not player.shift_button_pressed and multiplayer.is_server():
			transition.emit("Walking")
	else:
		if player.velocity.y < -3.0:
			transition.emit("Falling")
	
