extends Node3D

const DEFAULT_MATERIAL = preload('res://materials/main_pallete.tres')
const TRUE_MATERIAL = preload('res://materials/main_pallete_true.tres')
const FALSE_MATERIAL = preload('res://materials/main_pallete_false.tres')

@export var item_data : ItemDataCraftableBuildings
@export var building_part_owner_id : int
@export var building_colliders : Array[Area3D]
@export var shape_cast : ShapeCast3D
@export var collision_shape : CollisionShape3D
@export var mesh_node : MeshInstance3D
@export var building_collision : Area3D

var is_able_to_build : bool
