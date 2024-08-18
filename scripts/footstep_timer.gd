extends Timer

@export var sound_footstep_pool : SoundPool

func _on_timeout() -> void:
	sound_footstep_pool.play_random_sound()