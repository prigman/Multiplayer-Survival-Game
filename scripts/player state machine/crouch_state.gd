extends PlayerMovementState
class_name CrouchState

var speed_state : float
var crouch_state := 3.0

@export var animator : AnimationPlayer

func enter(_previous_state : State) -> void:
	# print("enter crouch for peer id", player.peer_id)
	animator.play("player_state/crouch_state")

func physics_update(delta : float) -> void:
	if player.item.Scoped:
		speed_state = crouch_state / 2
	else:
		speed_state = crouch_state

	if multiplayer.get_unique_id() == player.peer_id:
		player.input_sync.update_gravity(delta)
		player.input_sync.update_input(speed_state, ACCELERATION, DECCELERATION)
		player.input_sync.update_velocity()
		# if Input.is_action_just_released("left_ctrl"):
			# player.crouch_button_pressed = false
			# rpc_id(1, "RPC_crouch_button_pressed", false)
			# uncrouch(delta)
	else:
		player.update_gravity(delta)
		player.update_input(speed_state, ACCELERATION, DECCELERATION)
		player.update_velocity()

	if not player.crouch_button_pressed and multiplayer.is_server():
		uncrouch()

	if player.died:
		transition.emit("Death")
	if player.velocity.y < 0:
		transition.emit("Falling")
	
func uncrouch() -> void:
	if not player.spherecast.is_colliding() and not player.crouch_button_pressed:
		animator.play_backwards("player_state/crouch_state")
		if animator.current_animation == "player_state/crouch_state":
			await animator.animation_finished
			transition.emit("Idle")
	elif player.spherecast.is_colliding():
		await get_tree().create_timer(0.1).timeout
		uncrouch()
