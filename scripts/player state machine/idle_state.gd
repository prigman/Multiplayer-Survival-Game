extends PlayerMovementState
class_name IdleState

@export var speed_state := 5.0
var fall_damage: float
var fall_distance: float

func physics_update(delta : float) -> void:
	if multiplayer.get_unique_id() == player.peer_id:
		player.input_sync.update_gravity(delta)
		player.input_sync.update_input(speed_state, ACCELERATION, DECCELERATION)
		player.input_sync.update_velocity()
	else:
		player.update_gravity(delta)
		player.update_input(speed_state, ACCELERATION, DECCELERATION)
		player.update_velocity()

	if player.died:
		transition.emit("Death")

	elif player.is_on_floor():
		if player.crouch_button_pressed and multiplayer.is_server():
			transition.emit("Crouch")
		elif player.space_button_pressed and multiplayer.is_server():
			transition.emit("Jump")
		elif player.velocity.length() > 0.0:
			transition.emit("Walking")
	else:
		if player.velocity.y < -3:
			transition.emit("Falling")

func enter(previous_state : State) -> void:
	if previous_state is FallingState:
		fall_distance = previous_state.start_fall_y - player.global_transform.origin.y
		if fall_distance > 4:
			fall_damage = fall_distance * 1.5 
			player.died_process(fall_damage)
#print("Player took fall damage: ", fall_damage)

