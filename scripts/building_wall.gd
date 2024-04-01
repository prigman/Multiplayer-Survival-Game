extends Node3D

@onready var mesh_building = %CSGMesh3D12
@onready var shape_cast = %ShapeCast3D
@export var colliders : Array[Area3D]
@onready var coll_1 = $coll_1
@onready var coll_2 = $coll_2
@onready var coll_3 = $coll_3

