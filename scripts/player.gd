class_name Player extends CharacterBody3D

signal signal_toggle_inventory()
signal signal_update_player_stats(health: float, hunger: float)
signal signal_update_player_health(health: float)
signal signal_update_player_hunger(hunger: float)

var footstep_wait_time : float = 0.3

var last_position_x : float
var last_position_z : float
var distance_travelled_x : float = 0.0
var distance_travelled_z : float = 0.0

@export var sound_footstep_pool : SoundPool

# movement
# var camera_holder_position
var direction := Vector3.ZERO
# var input_direction
var gravity := 12.0 # ProjectSettings.get_setting("physics/3d/default_gravity")

# stats
@export var hunger_value: float = 100.0
@export var health_value: float = 50.0
var died: bool = false

var def_weapon_holder_pos: Vector3

var main_scene : Node3D

@export var footstep_timer : Timer

@export var peer_id: int

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
@export var weapon_sway_amount: float = 5.0
@export var weapon_rotation_amount: float = 1.0
@export var invert_weapon_sway: bool = false

@onready var spherecast := %ShapeCast3D
@onready var camera := %Camera3D
@onready var interact_ray := %InteractRay
@onready var inventory_interface := %InventoryInterface
@onready var item := %Item
@onready var player_stats := %PlayerStats
@onready var craft_menu := %CraftMenu
@onready var input_sync := %InputSync
@onready var sync := %MultiplayerSynchronizer
@onready var canvas_layer := %CanvasLayer
@onready var debug_ui := %Debug
@onready var label_3d := %Label3D

func _ready() -> void:
	if not is_multiplayer_authority():
		label_3d.show()
		label_3d.text = name
		return
	canvas_layer.show()
	signal_toggle_inventory.connect(_toggle_inventory_interface)
	inventory_interface._set_player_inventory_data(player_inventory)
	inventory_interface._set_quick_slot_data(player_quick_slot)
	inventory_interface.signal_drop_item.connect(_on_inventory_interface_signal_drop_item)
	inventory_interface.signal_force_close.connect(_toggle_inventory_interface)
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.signal_toggle_inventory.connect(_toggle_inventory_interface)
	def_weapon_holder_pos = weapon_holder.position
	spherecast.add_exception($".")
	signal_update_player_stats.emit(health_value, hunger_value)
	main_scene = get_parent().get_parent()

func _process(delta) -> void:
	var velocity_string = "%.2f" % velocity.length()
	debug_ui.add_property("velocity", velocity_string, + 1)
	if item.equiped_item_node:
		weapon_tilt(input_sync.input_direction.x, delta)
		weapon_sway(delta)
		weapon_bob(velocity.length(), delta)
	if (position.y <= -50.0):
		get_tree().reload_current_scene()
	
	

@rpc("any_peer","reliable","call_local")
func died_process(damage:int)-> void:
	if not is_multiplayer_authority():
		return
	health_value -= damage
	signal_update_player_health.emit(health_value)
	if health_value <= 0 and died==false :
		died = true
		print("Died player ",peer_id)
		main_scene.rpc('delete_player_rpc',peer_id)
		

func _toggle_inventory_interface(external_inventory_owner=null) -> void:
	if not is_multiplayer_authority():
		return
	inventory_interface.visible = not inventory_interface.visible
	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if !craft_menu.visible:
			craft_menu.show()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if inventory_interface.inv_item_info_panel.visible:
		inventory_interface.inv_item_info_panel.hide()
	if external_inventory_owner and inventory_interface.visible:
		if craft_menu.visible:
			craft_menu.hide()
		inventory_interface._set_external_inventory(external_inventory_owner)
	else:
		inventory_interface._clear_external_inventory()

# ------------ Player states

func update_gravity(delta) -> void:
	if not is_multiplayer_authority():
		return
	if not is_on_floor():
		velocity.y -= gravity * delta
	
func update_input(speed, acceleration, decceleration) -> void:
	if not is_multiplayer_authority():
		return
	direction = transform.basis * Vector3(input_sync.input_direction.x, 0, input_sync.input_direction.y).normalized()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, decceleration)
		velocity.z = move_toward(velocity.z, 0, decceleration)
		
	if is_on_floor():
		play_footsteps_sound()

func play_footsteps_sound():
	var current_position_x = global_transform.origin.x
	var current_position_z = global_transform.origin.z

	distance_travelled_x += abs(current_position_x - last_position_x)
	distance_travelled_z += abs(current_position_z - last_position_z)

	last_position_x = current_position_x
	last_position_z = current_position_z

	if distance_travelled_x >= 1.5 or distance_travelled_z >= 1.5:
		sound_footstep_pool.play_random_sound()
		distance_travelled_x = 0.0
		distance_travelled_z = 0.0

func update_velocity() -> void:
	if not is_multiplayer_authority():
		return
	move_and_slide()

# ------------ Inventory items interaction

func _on_inventory_interface_signal_drop_item(slot_data: InSlotData) -> void:
	var dict_slot_data := slot_data.serialize_data()
	var dict_item_data := slot_data.item.serialize_item_data()
	var item_data_scene := slot_data.item.dictionary
	var random_number := RandomNumberGenerator.new().randi_range(1000, 9999)
	var drop_position := get_drop_position()
	main_scene.item_spawner.rpc_id(1, 'request_spawn_item', random_number, drop_position, dict_slot_data, dict_item_data, item_data_scene)

func interact() -> void:
	if interact_ray.is_colliding():
		var collider : Object = interact_ray.get_collider()
		if collider.is_in_group('external_inventory'):
			collider._player_interact(player_inventory, player_quick_slot)
		else:
			if collider._player_interact(self) == true:
				rpc('delete_item', collider.get_path())

@rpc("any_peer", "reliable", "call_local")
func delete_item(inventory_item_interacted_path : NodePath) -> void:
	if not multiplayer.is_server(): return
	var inventory_item_interacted : Node = get_node(inventory_item_interacted_path)
	print("SERVER: delete_item function called on item %s" % inventory_item_interacted.name)
	inventory_item_interacted.queue_free()

func get_drop_position() -> Vector3:
	var drop_direction = -camera.global_transform.basis.z
	return camera.global_position + drop_direction

#-Camera and weapon tilt
func weapon_tilt(input_x, delta) -> void:
	if weapon_holder:
		weapon_holder.rotation.z = lerp(weapon_holder.rotation.z, -input_x * weapon_rotation_amount * 10, 10 * delta)

func weapon_sway(delta) -> void:
	input_sync.mouse_input = lerp(input_sync.mouse_input, Vector2.ZERO, 10 * delta)
	weapon_holder.rotation.x = lerp(weapon_holder.rotation.x, input_sync.mouse_input.y * weapon_rotation_amount * ( - 1 if invert_weapon_sway else 1), 10 * delta)
	weapon_holder.rotation.y = lerp(weapon_holder.rotation.y, input_sync.mouse_input.x * weapon_rotation_amount * ( - 1 if invert_weapon_sway else 1), 10 * delta)
	
func weapon_bob(vel: float, delta) -> void:
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
	
func is_inventory_open() -> bool:
	return inventory_interface.visible
	
func get_inventory_slots() -> Array[InSlotData]:
	if !player_inventory:
		push_error("Set player_inventory in Player node")
		return []
	return player_inventory.slots_data

func get_quick_slots() -> Array[InSlotData]:
	if !player_quick_slot:
		push_error("Set player_quick_slot in Player node")
		return []
	return player_quick_slot.slots_data
	
func give_item(slot_data: InSlotData) -> bool:
	if !player_inventory._pick_up_slot_data(slot_data) \
		and !player_quick_slot._pick_up_slot_data(slot_data):
		inventory_interface.signal_drop_item.emit(slot_data)
		return false
	else:
		return true
