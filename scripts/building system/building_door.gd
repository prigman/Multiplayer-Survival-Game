extends StaticBody3D

@export var animation_player : AnimationPlayer
@export var closed : bool = true

func _player_interact() -> void:
	rpc("play_animation")

@rpc("any_peer", "call_local", "reliable")
func play_animation() -> void:
	if animation_player.is_playing(): return
	if closed:
		animation_player.play("door_animation")
	else:
		animation_player.play_backwards("door_animation")
	closed = not closed