extends StaticBody3D

signal world_resource_hit(decrease_health_value : float)

enum WorldResourceType {
	tree,
	rock_1,
	rock_2,
	rock_3
}

@export var health : float
@export var timer : Timer
@export var zone : ShapeCast3D
@export var mesh : MeshInstance3D
@export var collision : CollisionShape3D
@export var start_health : float
@export var world_resource_type : WorldResourceType

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = start_health

func _on_timer_timeout() -> void:
	if !zone.is_colliding():
		timer.stop()
		zone.hide()
		zone.enabled = false
		health = start_health
		collision.disabled = false
		mesh.show()

func _on_world_resource_hit(decrease_health_value : float) -> void:
	health -= decrease_health_value
	if health <= 0.0:
		if mesh.visible:
			mesh.hide()
		if collision.disabled == false:
			collision.disabled = true
		if !zone.visible:
			zone.show()
		if !zone.enabled:
			zone.enabled = true
		if timer.is_stopped():
			timer.start()
