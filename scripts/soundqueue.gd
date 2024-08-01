class_name SoundQueue extends Node3D

@export var count : int = 1
var _next : int = 0
var audio_next : int = 0
var audio_list : Array[AudioStreamPlayer3D] = []


# Called when the node enters the scene tree for the first time.
func _ready():
	if get_child_count() == 0:
		push_error('No AudioStreamPlayer child found')
		return

	var child = get_child(0)
	if child is AudioStreamPlayer3D:
		audio_list.append(child)
		for i in range(count):
			var new_audio : AudioStreamPlayer3D = child.duplicate()
			add_child(new_audio)
			audio_list.append(new_audio)

func play_sound():
	if not audio_list[_next].is_playing():
		audio_list[_next].play()
		_next += 1
		_next %= audio_list.size()
