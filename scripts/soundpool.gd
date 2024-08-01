class_name SoundPool extends Node3D

var sound_list : Array[SoundQueue] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is SoundQueue:
			sound_list.append(child)

func play_random_sound():
	print("play random sound")
	var index : int = RandomNumberGenerator.new().randi_range(0, sound_list.size() -1)
	sound_list[index].play_sound()