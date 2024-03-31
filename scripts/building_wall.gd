extends Node3D

@onready var mesh_building = %CSGMesh3D12
@onready var shape_cast = %ShapeCast3D
@export var colliders : Array[Area3D]
