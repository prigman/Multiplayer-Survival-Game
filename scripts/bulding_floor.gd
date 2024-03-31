extends Node3D

@onready var mesh_building = %CSGMesh3D12
@onready var shape_cast = %ShapeCast3D
@export var colliders : Array[Area3D]
@onready var coll_1 = $coll_1
@onready var coll_2 = $coll_2
@onready var coll_3 = $coll_3
@onready var coll_4 = $coll_4


func _on_coll_1_area_entered(area):
	print("coll_1 disabled")
	coll_1.get_child(0).call_deferred("set_disabled", true)
	area.get_child(0).call_deferred("set_disabled", false)
	area.busy_for_place_floor = true

func _on_coll_2_area_entered(area):
	print("coll_2 disabled")
	coll_2.get_child(0).call_deferred("set_disabled", true)
	area.get_child(0).call_deferred("set_disabled", false)
	area.busy_for_place_floor = true

func _on_coll_3_area_entered(area):
	print("coll_3 disabled")
	coll_3.get_child(0).call_deferred("set_disabled", true)
	area.get_child(0).call_deferred("set_disabled", false)
	area.busy_for_place_floor = true

func _on_coll_4_area_entered(area):
	print("coll_4 disabled")
	coll_4.get_child(0).call_deferred("set_disabled", true)
	area.get_child(0).call_deferred("set_disabled", false)
	area.busy_for_place_floor = true
