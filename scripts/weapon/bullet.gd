extends Node3D

@onready var mesh_instance_3d = %MeshInstance3D

var bullet_speed = 500.0
var bullet_step_distance = 1.0 # Дистанция шага пули

func _physics_process(delta):
	position += transform.basis * Vector3(0, 0, -bullet_speed) * delta

func _on_timer_timeout():
	queue_free()

func _on_area_3d_body_entered(body):
	if body:
		print("Bullet hit %s" % body.name)
		queue_free()
