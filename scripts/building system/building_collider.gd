extends Area3D

enum ColliderType {
	floor,
	wall,
	roof,
	other,
}

@export var collider_type : ColliderType