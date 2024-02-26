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
@export var equiped_inv_item : InSlotData = null

var item_object_instantiate : Node3D = null

#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


#tilt weapon
@export var weapon_holder : Node3D
@export var weapon_sway_amount : float = 5
@export var weapon_rotation_amount : float = 1
@export var invert_weapon_sway : bool = false

@onready var spherecast = %ShapeCast3D
@onready var camera_holder = %CameraHolder
@onready var camera = %Camera3D
@onready var interact_ray = $CameraHolder/Camera3D/InteractRay
@onready var items_holder = $CameraHolder/ArmsHolder/ItemsHolder

@onready var weapons_manager = $CameraHolder/ArmsHolder/weapons_manager

var def_weapon_holder_pos : Vector3
var mouse_input : Vector2

func _ready():
	Global.global_player = self
	camera_holder_position = camera_holder.position.y
	def_weapon_holder_pos = weapon_holder.position
	spherecast.add_exception($".")


func _process(_delta):
	var velocity_string = "%.2f" % velocity.length()
	Global.global_debug.add_property("velocity", velocity_string, +1)
	if equiped_inv_item:
		weapon_tilt(input_dir.x, _delta)
		weapon_sway(_delta)
		weapon_bob(velocity.length(), _delta)
		
func _input(event):
	
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		camera_holder.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		camera_holder.rotation.x = clamp(camera_holder.rotation.x, deg_to_rad(-85), deg_to_rad(85))
		mouse_input = event.relative

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
		if item_object_instantiate.slot_data.item.item_type == item_object_instantiate.slot_data.item.ItemType.weapon:
			weapons_manager.exit(item_object_instantiate.slot_data)
		item_object_instantiate.queue_free()
		item_object_instantiate = null
	if equiped_item:
		if equiped_item.item.properties.has("equip_item"):
			var object_source = load(equiped_item.item.properties["equip_item"])
			item_object_instantiate = object_source.instantiate()
			item_object_instantiate.slot_data = equiped_item
			if item_object_instantiate.slot_data.item.item_type == item_object_instantiate.slot_data.item.ItemType.weapon:
				weapons_manager.add_child(item_object_instantiate)
				weapons_manager.initialize_weapon(item_object_instantiate)
			else:
				items_holder.add_child(item_object_instantiate)

#-Camera and weapon tilt
func weapon_tilt(input_x, delta):
	if weapon_holder:
		weapon_holder.rotation.z = lerp(weapon_holder.rotation.z, -input_x * weapon_rotation_amount * 10, 10 * delta)

func weapon_sway(delta):
	mouse_input = lerp(mouse_input,Vector2.ZERO,10*delta)
	weapon_holder.rotation.x = lerp(weapon_holder.rotation.x, mouse_input.y * weapon_rotation_amount * (-1 if invert_weapon_sway else 1), 10 * delta)
	weapon_holder.rotation.y = lerp(weapon_holder.rotation.y, mouse_input.x * weapon_rotation_amount * (-1 if invert_weapon_sway else 1)+1.54, 10 * delta)
	
func weapon_bob(vel : float, delta):
	if weapon_holder:
		if vel > 0 and is_on_floor():
			var bob_amount : float = 0.01
			var bob_freq : float = 0.01
			weapon_holder.position.y = lerp(weapon_holder.position.y, def_weapon_holder_pos.y + sin(Time.get_ticks_msec() * bob_freq) * bob_amount, 10 * delta)
			weapon_holder.position.x = lerp(weapon_holder.position.x, def_weapon_holder_pos.x + sin(Time.get_ticks_msec() * bob_freq * 0.5) * bob_amount, 10 * delta)
			
		else:
			weapon_holder.position.y = lerp(weapon_holder.position.y, def_weapon_holder_pos.y, 10 * delta)
			weapon_holder.position.x = lerp(weapon_holder.position.x, def_weapon_holder_pos.x, 10 * delta)
#-------
