class_name Scope 
extends PlayerMovementState
@export var speed_state = 5.0
var Scoped: bool = false 

func enter(_previous_state):
	pass

func physics_update(delta):
	player.update_gravity(delta)
	player.update_input(speed_state, ACCELERATION, DECCELERATION)
	player.update_velocity()
	if Input.is_action_pressed("right_click"):
		$"../../Interface/Reticle".hide()
		if !Scoped:
			Assault_Rifle_Scope()
	if Input.is_action_just_released("right_click"):
		if Scoped:
			Assault_Rifle_Scope()
			$"../../Interface/Reticle".show()
	if player.is_on_floor():
		if Input.is_action_pressed("left_ctrl"):
			transition.emit("Crouch")
			
	if player.velocity.length() > 0:
		transition.emit("Walking")
	if Input.is_action_pressed("shift"):
		player.animator.play_backwards(player.equiped_inv_item.item.anim_scope)
		$"../../Interface/Reticle".show()
		transition.emit("Sprint")
		
func Assault_Rifle_Scope():
	if !Scoped:
		player.animator.play(player.equiped_inv_item.item.anim_scope)
	else:
		player.animator.play_backwards(player.equiped_inv_item.item.anim_scope)
	Scoped = !Scoped
