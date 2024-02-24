class_name IdleState
extends PlayerMovementState

@export var speed_state = 5.0

func physics_update(delta):
	player.update_gravity(delta)
	player.update_input(speed_state, ACCELERATION, DECCELERATION)
	player.update_velocity()
	if player.equiped_inv_item:
		if player.equiped_inv_item.item.item_type == player.equiped_inv_item.item.ItemType.weapon:
			if Input.is_action_pressed("right_click"):
				transition.emit("Scope")
	if player.is_on_floor():
		if Input.is_action_pressed("left_ctrl"):
			transition.emit("Crouch")
		if player.velocity.length() > 0:
			transition.emit("Walking")
		if Input.is_action_just_pressed("space"):
			transition.emit("Jump")
