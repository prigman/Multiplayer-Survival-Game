extends PlayerMovementState
class_name FallingState

@export var speed_state := 5.0

var start_fall_y: float = 0.0

func physics_update(delta : float) -> void:
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
		transition.emit("Idle")

func enter(_previous_state : State) -> void:
	if multiplayer.is_server():
		start_fall_y = player.global_transform.origin.y
