extends Area3D

enum ColliderType {
	floor,
	wall,
	roof,
	door,
}

@export var collider_type : ColliderType
@export var door_root : Marker3D