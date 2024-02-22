class_name Scope 
extends PlayerMovementState

var Scoped: bool = false 

func enter(_previous_state):
	pass
	
func physics_update(delta):
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
		if Input.is_action_just_pressed("space"):
			transition.emit("Jump")
		
func Assault_Rifle_Scope():
	if !Scoped:
		player.AnimPlayer.play("Assault Rifle Scope")
	else:
		player.AnimPlayer.play_backwards("Assault Rifle Scope")
	Scoped = !Scoped

