class_name JumpState 
extends PlayerMovementState

@export var speed_state := 5.0
@export var jump_velocity := 4.5
@export_range(0.5, 1.0, 0.01) var input_multiplier := .85

func enter(_previous_state : State) -> void:
	player.velocity.y += jump_velocity
	
func physics_update(delta : float) -> void:
	# if multiplayer.get_unique_id() == player.peer_id:
	# 	player.input_sync.update_gravity(delta)
	# 	player.input_sync.update_input(speed_state * input_multiplier, ACCELERATION, DECCELERATION)
	# 	player.input_sync.update_velocity()
	# else:
	player.update_gravity(delta)
	player.update_input(speed_state * input_multiplier, ACCELERATION, DECCELERATION)
	player.update_velocity()
	if player.died:
		transition.emit("Death")
	elif player.velocity.y < 0:
		transition.emit("Falling")
	elif not player.space_button_pressed and multiplayer.is_server():
		if player.velocity.y > 0:
			player.velocity.y = player.velocity.y / 2.0
	elif player.is_on_floor():
		if player.velocity.y == 0:
			transition.emit("Idle")
