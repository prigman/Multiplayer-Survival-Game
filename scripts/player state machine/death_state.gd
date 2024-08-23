class_name DeathState
extends PlayerMovementState

func enter(_previous_state : State) -> void:
	player.on_player_die()

func physics_update(_delta : float) -> void:
	if not player.died:
		transition.emit("Idle")