@tool

extends Node3D

@onready var objects_spawned := %ObjectsSpawned

@export var raycast : RayCast3D
@export var collision_shape : CollisionShape3D

@export var objects : Array[ObjectsCreatorRes]

@export var count := 10

@export var random_rotation : Vector3
@export var random_scale : float = 1

@export var create_objects_button : bool = false :
	set(value):
		value = true
		create_object.call_deferred(value)

@export var remove_objects_button : bool = false :
	set(value):
		value = true
		remove_object.call_deferred(value)


func create_object(value : bool) -> void:
	value = false
	var rng := RandomNumberGenerator.new()
	for obj in objects:
		if obj:
			for i in obj.count:
				raycast.position = get_random_position_in_collision_shape()
				raycast.force_raycast_update()
				var ray_end_point := raycast.get_collision_point()
				if ray_end_point:
					var obj_instance := obj.object.instantiate()
					objects_spawned.add_child(obj_instance)
					obj_instance.owner = get_tree().edited_scene_root
					set_editable_instance(obj_instance, false)
					obj_instance.global_position = ray_end_point
					if random_rotation != Vector3(0,0,0):
						var random_rot_x := rng.randf_range(0, random_rotation.x)
						var random_rot_y := rng.randf_range(0, random_rotation.y)
						var random_rot_z := rng.randf_range(0, random_rotation.z)
						obj_instance.rotation = Vector3(random_rot_x, random_rot_y, random_rot_z)
					if random_scale != 1:
						var _random_scale := rng.randf_range(1, random_scale)
						obj_instance.scale = Vector3(random_scale, random_scale, random_scale)
				else:
					print("No ray_end_point found")
					break

func remove_object(value : bool) -> void:
	value = false
	for child in objects_spawned.get_children():
		if child:
			objects_spawned.remove_child(child)
			child.queue_free()

func get_random_position_in_collision_shape() -> Vector3:
	var shape = collision_shape.shape
	if shape is BoxShape3D:
		var random_x = randf_range(-shape.size.x / 2, shape.size.x / 2)
		var random_z = randf_range(-shape.size.z / 2, shape.size.z / 2)
		return Vector3(random_x, raycast.position.y, random_z)
	else:
		return Vector3.ZERO