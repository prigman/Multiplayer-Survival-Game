class_name Player extends CharacterBody3D

signal signal_toggle_inventory()
signal signal_update_player_stats(health: float, hunger: float)
signal signal_update_player_health(health: float)
signal signal_update_player_hunger(hunger: float)

# movement
var camera_holder_position
var input_dir = Vector2.ZERO
var direction = Vector3.ZERO
var gravity = 12.0 # ProjectSettings.get_setting("physics/3d/default_gravity")

# stats
var hunger_value: float = 100.0
var health_value: float = 100.0

var def_weapon_holder_pos: Vector3
var mouse_input: Vector2

@export var mouse_sens = 0.15

# inv
@export var player_inventory: InventoryData
@export var player_quick_slot: InventoryData

# spread data
@export var weapon_spread_data: Array[PlayerWeaponSpread] # массив с данными разброса для всего доступного оружия
var current_weapon_spread_data: PlayerWeaponSpread = null # сюда назначается то оружие, которое игрок держит сейчас в руках

# building system
@export var buildings_in_own: Array[Node3D]

# tilt weapon
@export var weapon_holder: Node3D
@export var weapon_sway_amount: float = 5
@export var weapon_rotation_amount: float = 1
@export var invert_weapon_sway: bool = false

@onready var spherecast = %ShapeCast3D
@onready var camera_holder = %CameraHolder
@onready var camera = %Camera3D
@onready var interact_ray = %InteractRay
@onready var inventory_interface = %InventoryInterface
@onready var item = %Item
@onready var player_stats = %PlayerStats
@onready var craft_menu = %CraftMenu

func _ready():
	Global.global_player = self
	Global.global_player_quick_slot = player_quick_slot
	Global.global_player_inventory = player_inventory
	camera_holder_position = camera_holder.position.y
	def_weapon_holder_pos = weapon_holder.position
	spherecast.add_exception($".")
	signal_update_player_stats.emit(health_value, hunger_value)

func _process(delta):
	var velocity_string = "%.2f" % velocity.length()
	Global.global_debug.add_property("velocity", velocity_string, + 1)
	if item.equiped_item_node:
		weapon_tilt(input_dir.x, delta)
		weapon_sway(delta)
		weapon_bob(velocity.length(), delta)
		
func _input(event):
	if event is InputEventMouseMotion and !inventory_interface.visible:
		rotate_y(deg_to_rad( - event.relative.x * mouse_sens))
		camera_holder.rotate_x(deg_to_rad( - event.relative.y * mouse_sens))
		camera_holder.rotation.x = clamp(camera_holder.rotation.x, deg_to_rad( - 85), deg_to_rad(85))
		mouse_input = event.relative

func _unhandled_input(event):
	if event.is_action_pressed("inv_toggle"):
		signal_toggle_inventory.emit()
	if event.is_action_pressed("interact"):
		interact()

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
		interact_ray.get_collider()._player_interact(player_inventory, player_quick_slot)

func get_drop_position() -> Vector3:
	var drop_direction = -camera.global_transform.basis.z
	return camera.global_position + drop_direction

#-Camera and weapon tilt
func weapon_tilt(input_x, delta):
	if weapon_holder:
		weapon_holder.rotation.z = lerp(weapon_holder.rotation.z, -input_x * weapon_rotation_amount * 10, 10 * delta)

func weapon_sway(delta):
	mouse_input = lerp(mouse_input, Vector2.ZERO, 10 * delta)
	weapon_holder.rotation.x = lerp(weapon_holder.rotation.x, mouse_input.y * weapon_rotation_amount * ( - 1 if invert_weapon_sway else 1), 10 * delta)
	weapon_holder.rotation.y = lerp(weapon_holder.rotation.y, mouse_input.x * weapon_rotation_amount * ( - 1 if invert_weapon_sway else 1), 10 * delta)
	
func weapon_bob(vel: float, delta):
	if weapon_holder:
		if vel > 0 and is_on_floor() and !item.Scoped:
			var bob_amount: float = 0.01
			var bob_freq: float = 0.01
			weapon_holder.position.y = lerp(weapon_holder.position.y, def_weapon_holder_pos.y + sin(Time.get_ticks_msec() * bob_freq) * bob_amount, 10 * delta)
			weapon_holder.position.x = lerp(weapon_holder.position.x, def_weapon_holder_pos.x + sin(Time.get_ticks_msec() * bob_freq * 0.5) * bob_amount, 10 * delta)
			
		else:
			weapon_holder.position.y = lerp(weapon_holder.position.y, def_weapon_holder_pos.y, 10 * delta)
			weapon_holder.position.x = lerp(weapon_holder.position.x, def_weapon_holder_pos.x, 10 * delta)
#-------
