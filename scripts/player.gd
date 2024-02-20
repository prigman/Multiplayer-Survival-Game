class_name Player
extends CharacterBody3D

signal signal_toggle_inventory()
signal signal_equip_inv_item(quick_slot_inv : InventoryData, equiped_item : InSlotData, index : int)

var camera_holder_position
var input_dir = Vector2.ZERO
var direction = Vector3.ZERO
var gravity = 12.0


@export var mouse_sens = 0.15

@export var player_inventory : InventoryData
@export var player_quick_slot : InventoryData
@export var equiped_inv_item : InSlotData
var item_object_instantiate

#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var spherecast = %ShapeCast3D
@onready var camera_holder = %CameraHolder
@onready var camera = %Camera3D
@onready var interact_ray = $CameraHolder/Camera3D/InteractRay
@onready var items_holder = $CameraHolder/ArmsHolder/ItemsHolder

func _ready():
	Global.global_player = self
	camera_holder_position = camera_holder.position.y
	spherecast.add_exception($".")
	equiped_inv_item = null

func _process(_delta):
	var velocity_string = "%.2f" % velocity.length()
	Global.global_debug.add_property("velocity", velocity_string, +1)
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		camera_holder.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		camera_holder.rotation.x = clamp(camera_holder.rotation.x, deg_to_rad(-85), deg_to_rad(85))

func _unhandled_input(event):
	if event.is_action_pressed("inv_toggle"):
		signal_toggle_inventory.emit()
	if event.is_action_pressed("interact"):
		interact()
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				signal_equip_inv_item.emit(player_quick_slot, equiped_inv_item, 0)
				if equiped_inv_item:
					print("equiped item info: %s" % equiped_inv_item.item.name)
			KEY_2:
				signal_equip_inv_item.emit(player_quick_slot, equiped_inv_item, 1)
				if equiped_inv_item:
					print("equiped item info: %s" % equiped_inv_item.item.name)
			KEY_3:
				signal_equip_inv_item.emit(player_quick_slot, equiped_inv_item, 2)
				if equiped_inv_item:
					print("equiped item info: %s" % equiped_inv_item.item.name)
			KEY_4:
				signal_equip_inv_item.emit(player_quick_slot, equiped_inv_item, 3)
				if equiped_inv_item:
					print("equiped item info: %s" % equiped_inv_item.item.name)
			KEY_5:
				signal_equip_inv_item.emit(player_quick_slot, equiped_inv_item, 4)
				if equiped_inv_item:
					print("equiped item info: %s" % equiped_inv_item.item.name)
			KEY_6:
				signal_equip_inv_item.emit(player_quick_slot, equiped_inv_item, 5)
				if equiped_inv_item:
					print("equiped item info: %s" % equiped_inv_item.item.name)


### Player states

func update_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
func update_input(speed, acceleration, decceleration):
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	direction = transform.basis * Vector3(input_dir.x, 0, input_dir.y).normalized()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, decceleration)
		velocity.z = move_toward(velocity.z, 0, decceleration)
	
func update_velocity():
	move_and_slide()

### Inventory items interaction

func interact():
	if interact_ray.is_colliding():
		interact_ray.get_collider()._player_interact(player_inventory)

func get_drop_position() -> Vector3:
	var drop_direction = -camera.global_transform.basis.z
	return camera.global_position + drop_direction
	

func instantiate_player_item(equiped_item : InSlotData):
	if item_object_instantiate:
		item_object_instantiate.queue_free()
		item_object_instantiate = null
	if equiped_item:
		if equiped_item.item.properties.has("equip_item"):
			var object_source = load(equiped_item.item.properties["equip_item"])
			item_object_instantiate = object_source.instantiate()
			#object.slot_data = equiped_item
			items_holder.add_child(item_object_instantiate)
			item_object_instantiate.position = Vector3.ZERO
