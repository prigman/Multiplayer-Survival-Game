extends Area3D

enum ColliderType {
	floor,
	wall,
	roof,
	other,
	door,
}

enum DoorType {
	not_door,
	front,
	back
}

@export var collider_type : ColliderType
@export var door_root : Node3D
@export var root_scene : StaticBody3D
@export var door_type : DoorType
@export var is_busy : bool