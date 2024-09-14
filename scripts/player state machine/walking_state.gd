class_name WalkingState
extends PlayerMovementState

var speed_state : float
var walking_state := 5.0
	
func physics_update(delta : float) -> void:
	if player.item.Scoped:
		speed_state = walking_state / 2
	else:
		speed_state = walking_state
	if multiplayer.get_unique_id() == player.peer_id:
		player.input_sync.update_gravity(delta)
		player.input_sync.update_input(speed_state, ACCELERATION, DECCELERATION)
		player.input_sync.update_velocity()
	else:
		player.update_gravity(delta)
		player.update_input(speed_state, ACCELERATION, DECCELERATION)
		player.update_velocity()
	if player.died and multiplayer.is_server():
		transition.emit("Death")
	if player.is_on_floor():
		if player.crouch_button_pressed and multiplayer.is_server():
			transition.emit("Crouch")
		elif player.space_button_pressed and multiplayer.is_server():
			transition.emit("Jump")
		elif player.shift_button_pressed and multiplayer.is_server():
			transition.emit("Sprint")
	elif player.velocity.y < -3.0:
		transition.emit("Falling")
	if player.velocity.length() == 0:
		transition.emit("Idle")
