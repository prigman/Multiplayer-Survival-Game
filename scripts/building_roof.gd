extends Node3D

@onready var mesh_building = %CSGMesh3D
@onready var shape_cast = %ShapeCast3D
@export var colliders : Array[Area3D]
@onready var coll_1 = $coll_1
@onready var coll_2 = $coll_2
@onready var coll_3 = $coll_3
@onready var coll_4 = $coll_4




func _on_coll_1_area_entered(area):
	print("coll_1 wall collider from roof disabled")
	area.get_child(0).call_deferred("set_disabled", true)


func _on_coll_2_area_entered(area):
	print("coll_2 wall collider from roof disabled")
	area.get_child(0).call_deferred("set_disabled", true)


func _on_coll_3_area_entered(area):
	print("coll_3 wall collider from roof disabled")
	area.get_child(0).call_deferred("set_disabled", true)


func _on_coll_4_area_entered(area):
	print("coll_4 wall collider from roof disabled")
	area.get_child(0).call_deferred("set_disabled", true)
