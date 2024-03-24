extends CharacterBody3D

var health = 120

func _process(_delta):
	if health <= 0:
		hide()
		health = 120
		print("Enemy killed")
