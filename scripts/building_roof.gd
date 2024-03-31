extends Node3D

@onready var mesh_building = %CSGMesh3D
@onready var shape_cast = %ShapeCast3D
@export var colliders : Array[Area3D]


func _on_coll_1_area_entered(area):
	area.get_child(0).disabled = true


func _on_coll_2_area_entered(area):
	area.get_child(0).disabled = true


func _on_coll_3_area_entered(area):
	area.get_child(0).disabled = true


func _on_coll_4_area_entered(area):
	area.get_child(0).disabled = true
