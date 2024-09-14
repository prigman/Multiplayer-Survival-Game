extends Node3D

func _on_timer_timeout() -> void:
	if not multiplayer.is_server(): return
	queue_free()
