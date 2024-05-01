extends Node3D

var can_be_placed : bool
var able_to_building : bool = true
var is_in_building_place : bool
@export var disable_building_collider : ShapeCast3D
@export var building_part_shape : ShapeCast3D
@export var building_part_area : Area3D
@export var private_area : Area3D
@export var temporary_building_area : Area3D
@export var building_part_owner : CharacterBody3D
@onready var mesh_building = %CSGMesh3D12
@onready var shape_cast = %ShapeCast3D
@export var colliders : Array[Area3D]
@onready var coll_1 = $coll_1
@onready var coll_2 = $coll_2
@onready var coll_3 = $coll_3
@onready var coll_4 = $coll_4

func connect_building_part(area, area2):
	if area2.is_in_group("building_colliders"):
		area2.connected_floor = area
		if area2.is_in_group("wall_connector"):
			area.connected_wall = area2
	

func _on_coll_1_area_entered(area):
	connect_building_part(coll_1, area)


func _on_coll_2_area_entered(area):
	connect_building_part(coll_2, area)


func _on_coll_3_area_entered(area):
	connect_building_part(coll_3, area)


func _on_coll_4_area_entered(area):
	connect_building_part(coll_4, area)

func _on_temporary_building_area_area_entered(area):
	if area.is_in_group("building_private_area"):
		if area.get_parent().get_parent().building_part_owner != building_part_owner:
			able_to_building = false
			print("building private area entered, able_to_building = false")

func _on_temporary_building_area_area_exited(area):
	if area.is_in_group("building_private_area"):
		able_to_building = true
		print("building private area exited, able_to_building = true")
