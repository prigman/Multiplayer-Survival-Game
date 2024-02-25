class_name Scope 
extends PlayerMovementState
@export var speed_state = 4.0
var Scoped: bool = false 

func enter(_previous_state):
	pass

func physics_update(delta):
	player.update_gravity(delta)
	player.update_input(speed_state, ACCELERATION, DECCELERATION)
	player.update_velocity()
		
func Assault_Rifle_Scope():
	if !Scoped:
		player.animator.play(player.equiped_inv_item.item.anim_scope)
	else:
		player.animator.play_backwards(player.equiped_inv_item.item.anim_scope)
	Scoped = !Scoped
