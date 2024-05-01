extends StaticBody3D

var health : float
@export var timer : Timer
@export var zone : ShapeCast3D
@export var mesh : MeshInstance3D
@export var collision : CollisionShape3D
@export var start_health : float

# Called when the node enters the scene tree for the first time.
func _ready():
	health = start_health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
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


func _on_timer_timeout():
	if !zone.is_colliding():
		zone.hide()
		zone.enabled = false
		health = start_health
		collision.disabled = false
		mesh.show()
