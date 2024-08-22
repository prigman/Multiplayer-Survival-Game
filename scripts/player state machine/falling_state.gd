extends PlayerMovementState
class_name FallingState

@export var speed_state := 5.0
	
func physics_update(delta : float) -> void:
	player.update_gravity(delta)
	player.update_input(speed_state, ACCELERATION, DECCELERATION)
	player.update_velocity()
	if player.died:
		transition.emit("Death")
	if player.is_on_floor():
		transition.emit("Idle")
