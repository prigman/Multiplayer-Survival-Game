class_name Player extends CharacterBody3D

signal signal_toggle_inventory()
signal signal_update_player_stats(health: float, hunger: float)
signal signal_update_player_health(health: float)
signal signal_update_player_hunger(hunger: float)


# footsteps sounds
var footstep_wait_time : float = 0.3

var last_position_x : float
var last_position_z : float
var distance_travelled_x : float = 0.0
var distance_travelled_z : float = 0.0
#

# movement
# var camera_holder_position
var direction := Vector3.ZERO
# var input_direction
var gravity := 12.0 # ProjectSettings.get_setting("physics/3d/default_gravity")

# stats
@export var died: bool = false

var def_weapon_holder_pos: Vector3

var main_scene : Node3D

var is_player_loading := true

var sprint_hunger_rate: float = 0.5
var walk_hunger_rate: float = 0.2
var idle_hunger_rate: float = 0.1

# @export var equiped_item_slot_id : int = -1

# rpc variables
@export var crouch_button_pressed : bool
@export var space_button_pressed : bool
@export var shift_button_pressed : bool
#

@export var hunger_value: float = 50.0
@export var health_value: float = 100.0

@export var connected_mobs : Array[Dictionary] = []

@export var peer_id: int = 1 :
	set(id):
		peer_id = id
		%InputSync.set_multiplayer_authority(id) # set authority to client only

# inv
# @export var player_inventory: InventoryData
# @export var player_quick_slot: InventoryData
# @export var serialized_player_inventory : Dictionary
# @export var serialized_player_quick_slot : Dictionary
#

# spread data
@export var weapon_spread_data : Array[PlayerWeaponSpread]
var current_weapon_spread_data: PlayerWeaponSpread # сюда назначается то оружие, которое игрок держит сейчас в руках

# building system
@export var buildings_in_own: Array[Dictionary] = []

# tilt weapon
@export var weapon_holder: Node3D
@export var weapon_sway_amount: float = 5.0
@export var weapon_rotation_amount: float = 1.0
@export var invert_weapon_sway: bool = false
#

@onready var sound_footstep_pool := %SoundPool
@onready var state_machine := %StateMachine
@onready var footstep_timer := %FootstepTimer
@onready var mesh := %MeshInstance3D
@onready var spherecast := %ShapeCast3D
@onready var camera := %Camera3D
@onready var interact_ray := %InteractRay
@onready var item := %Item
@onready var input_sync := %InputSync
@onready var collision := %DefaultStateCollision
@onready var camera_controller := %CameraController
@onready var label_3d := %Label3D
@onready var canvas_layer := %CanvasLayer
# @onready var inventory_interface := %InventoryInterface
# @onready var craft_menu := %CraftMenu
@onready var debug_ui := %Debug
@onready var player_stats := %PlayerStats
@onready var death_ui := %DeathUI
# @onready var quick_slot_ui := %PlayerQuickSlot
@onready var camera_holder := %CameraHolder

func _ready() -> void:
	main_scene = get_parent().get_parent()
	if not multiplayer.is_server():
		set_process(false)
		set_physics_process(false)
		set_process_input(false)
		set_process_unhandled_input(false)
		return
	label_3d.text = "Player_" + name

	#signal_toggle_inventory.connect(_toggle_inventory_interface)
	
	
	# 
	# inventory_interface._set_interact_player_inventory_data(player_inventory)
	# inventory_interface._set_interact_quick_slot_data(player_quick_slot)

	# serialized_player_inventory = player_inventory.serialize_inventory_data()
	# serialized_player_quick_slot = player_quick_slot.serialize_inventory_data()
	#
	
	
	# inventory_interface.signal_drop_item.connect(_on_inventory_interface_signal_drop_item)
	
	#inventory_interface.signal_use_item.connect(_on_inventory_interface_signal_use_item)
	#inventory_interface.signal_force_close.connect(_toggle_inventory_interface)
	#for node in get_tree().get_nodes_in_group("external_inventory"):
		#if node:
			#node.signal_toggle_inventory.connect(_toggle_inventory_interface)
	def_weapon_holder_pos = weapon_holder.position
	spherecast.add_exception($".")
	#signal_update_player_stats.emit(health_value, hunger_value)
	# await get_tree().create_timer(3.0).timeout
	# is_player_loading = false

func _exit_tree() -> void:
	if not connected_mobs.is_empty():
		disconnect_all_mobs_from_player()

func _physics_process(_delta: float) -> void:
	mesh.rotation.y = input_sync.camera_controller_input_rotation_y
	item.raycasts_controller.rotation.x = input_sync.camera_holder_input_rotation_x
	item.raycasts_controller.rotation.y = input_sync.camera_controller_input_rotation_y

func _process(delta : float) -> void:
	decrease_hunger_value(delta)
	# var velocity_string := "%.2f" % velocity.length()
	# debug_ui.add_property("velocity", velocity_string, + 1)
	# if not is_player_loading and item.equiped_item_node:
	# 	weapon_tilt(input_sync.input_direction.x, delta)
	# 	weapon_sway(delta)
	# 	weapon_bob(velocity.length(), delta)
	# if (position.y <= -50.0):
	# 	get_tree().reload_current_scene()

func decrease_hunger_value(delta: float) -> void:
	if state_machine.is_current_state("Sprint"): hunger_value -= sprint_hunger_rate * delta
	elif state_machine.is_current_state("Idle"): hunger_value -= idle_hunger_rate * delta
	else:hunger_value -= walk_hunger_rate * delta
	hunger_value = max(hunger_value, 0.0)
	#signal_update_player_hunger.emit(hunger_value)
	# rpc_id(peer_id, "update_player_hunger_ui", hunger_value)
	if hunger_value == 0.0 and health_value > 0.0:
		died_process(0.5*delta, "STARVING")
	elif hunger_value > 95 and health_value < 100:
		health_value+=0.5*delta
		

# @rpc("any_peer", "call_local", "reliable")
func connect_mob_to_player(mob : CharacterBody3D) -> void:
	for connected_mob in connected_mobs:
		if not connected_mob.is_empty() and connected_mob["mob_name"] == mob.name: return
	mob.target = self
	var dict_data : Dictionary
	dict_data["mob_name"] = mob.name
	connected_mobs.append(dict_data)
	print("SERVER: connect Mob " + mob.name + " to player " + str(peer_id))

# @rpc("any_peer", "call_local", "reliable")
func disconnect_all_mobs_from_player() -> void:
	var enemy_array := get_tree().get_nodes_in_group("enemy_group")
	for connected_mob in connected_mobs:
		for enemy in enemy_array:
			if enemy.name == connected_mob["mob_name"]:
				enemy.target = null
				break
	connected_mobs = []
	print("SERVER: disconnect all Mobs from player beacuse of leave: " + str(peer_id))

# @rpc("any_peer", "call_local", "reliable")
func disconnect_mob_from_player(mob : CharacterBody3D) -> void:
	if mob.target == self:
		mob.target = null
		for connected_mob in connected_mobs:
			if connected_mob["mob_name"] == mob.name:
				connected_mobs.erase(connected_mob)
				print("SERVER: disconnect Mob " + mob.name + " from player: " + str(peer_id))
				break

#@rpc("any_peer","reliable","call_local", 2)
func died_process(damage:float, damage_info : String) -> void:
	health_value -= damage
	print("DAMAGE LOG: " + str(peer_id) + " was hit by " + damage_info + " | with damage: " + str(damage) + " | health now: " + str(health_value))
	if health_value <= 0 and died==false :
		died = true
		print("DEATH LOG: " + str(peer_id) + " died")

@rpc("any_peer", "call_local", "reliable", 2)
func player_shot(damage:float, damage_peer_id: int = -1) -> void:
	health_value -= damage
	print("DAMAGE LOG: " + str(peer_id) + " was hit by " + str(damage_peer_id) + " | with damage: " + str(damage) + " | health now: " + str(health_value))
	if health_value <= 0 and died==false :
		died = true
		print("DEATH LOG: " + str(peer_id) + " died")

#@rpc("any_peer", "call_local", "reliable", 2)
#func update_player_health_ui(value: float) -> void:
	#signal_update_player_health.emit(value)

func on_player_die() -> void:
	# for slot in player_inventory.slots_data:
	# 	if slot:
	# 		var random_position_z := randf_range(global_position.z-1, global_position.z+1)
	# 		var random_position_x := randf_range(global_position.x-1, global_position.x+1)
	# 		drop_item_from_inventory(slot, Vector3(random_position_x, global_position.y+2, random_position_z), false)
	# for slot in player_quick_slot.slots_data:
	# 	if slot:
	# 		var random_position_z := randf_range(global_position.z-1, global_position.z+1)
	# 		var random_position_x := randf_range(global_position.x-1, global_position.x+1)
	# 		drop_item_from_inventory(slot, Vector3(random_position_x, global_position.y+2, random_position_z), false)
		#mesh.hide()
		#label_3d.hide()
		#collision.disabled = true
	rpc("toggle_player_visibility_on_server", false)
	rpc_id(peer_id, "RPC_on_player_die")
	if item.RPC_is_item_equiped:
		item.clear_server_item()
	# player_inventory._clear_inventory()
	# player_quick_slot._clear_inventory()

@rpc("any_peer", "call_local", "reliable", 2)
func toggle_player_visibility_on_server(player_visibility: bool) -> void:
	if multiplayer.get_unique_id() == peer_id: return
	if not player_visibility:
		mesh.hide()
		label_3d.hide()
		collision.disabled = true
	else:
		mesh.show()
		label_3d.show()
		collision.disabled = false

@rpc("any_peer", "call_local", "reliable")
func RPC_on_player_die() -> void:
	input_sync.set_process_for_player(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# if item.RPC_is_item_equiped:
	# 	item.clear_item(player_quick_slot, item.equiped_slot_index, item.equiped_slot)
	# if is_inventory_open(): inventory_interface.hide()
	item.reticle.hide()
	# quick_slot_ui.hide()
	player_stats.hide()
	death_ui.show()
	# player_inventory._clear_inventory()
	# player_quick_slot._clear_inventory()

func on_player_respawn() -> void:
	died = false
	rpc("toggle_player_visibility_on_server", true)
	hunger_value = 100
	health_value = 100
	position = Vector3.ZERO
	rotation = Vector3.ZERO
	rpc_id(peer_id, "spawn_local_player")

@rpc("any_peer", "call_local", "reliable", 2)
func spawn_local_player() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	death_ui.hide()
	player_stats.show()
	item.reticle.show()
	# quick_slot_ui.show()
	input_sync.set_process_for_player(true)

# func _toggle_inventory_interface(external_inventory_owner : ExternalInventory = null) -> void:
# 	inventory_interface.visible = not inventory_interface.visible
# 	if inventory_interface.visible:
# 		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
# 		if !craft_menu.visible:
# 			craft_menu.show()
# 	else:
# 		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
# 	if inventory_interface.inv_item_info_panel.visible:
# 		inventory_interface.inv_item_info_panel.hide()
# 	if external_inventory_owner and inventory_interface.visible:
# 		if craft_menu.visible:
# 			craft_menu.hide()
# 		inventory_interface._set_external_inventory(external_inventory_owner)
# 	else:
# 		inventory_interface._clear_external_inventory()

# # ------------ Player states

func update_gravity(delta : float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	
func update_input(speed : float, acceleration : float, decceleration : float) -> void:
	direction = mesh.transform.basis * Vector3(input_sync.input_direction.x, 0, input_sync.input_direction.y).normalized()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, decceleration)
		velocity.z = move_toward(velocity.z, 0, decceleration)
		
	if is_on_floor():
		play_footsteps_sound()

func play_footsteps_sound() -> void:
	var current_position_x := global_transform.origin.x
	var current_position_z := global_transform.origin.z

	distance_travelled_x += abs(current_position_x - last_position_x)
	distance_travelled_z += abs(current_position_z - last_position_z)

	last_position_x = current_position_x
	last_position_z = current_position_z

	if distance_travelled_x >= 1.5 or distance_travelled_z >= 1.5:
		distance_travelled_x = 0.0
		distance_travelled_z = 0.0
		rpc("RPC_play_footsteps_sound")

@rpc("any_peer", "unreliable", "call_local", 0)
func RPC_play_footsteps_sound() -> void:
	# if multiplayer.get_unique_id() == peer_id: return
	sound_footstep_pool.play_random_sound()

func update_velocity() -> void:
	move_and_slide()

# ------------ Inventory items interaction

# func _on_inventory_interface_signal_drop_item(slot_data: InSlotData) -> void:
	
# 	drop_item_from_inventory(slot_data, get_drop_position())

# func _on_inventory_interface_signal_use_item(slot_data: InSlotData) -> void:
# 	var item_data := slot_data.item
# 	if item_data.health_value > 0 and health_value < 100.0:
# 		health_value = min(health_value + item_data.health_value, 100.0)
# 		signal_update_player_health.emit(health_value)
# 	if item_data.hunger_value > 0 and hunger_value < 100.0:
# 		hunger_value = min(hunger_value + item_data.hunger_value, 100.0)
# 		signal_update_player_hunger.emit(hunger_value)

# func drop_item_from_inventory(slot_data : InSlotData, item_position : Vector3, from_local : bool = true) -> void:
# 	var item_data_scene := slot_data.item.dictionary
# 	if not item_data_scene.has('dropped_item'): return
# 	var dict_slot_data := slot_data.serialize_data()
# 	var dict_item_data := slot_data.item.serialize_item_data()
# 	var random_number := RandomNumberGenerator.new().randi_range(1000, 9999)
# 	var drop_position := item_position
# 	if from_local:
# 		main_scene.item_spawner.rpc_id(1, "request_spawn_item", random_number, drop_position, dict_slot_data, dict_item_data, item_data_scene)
# 	else:
# 		main_scene.item_spawner.request_spawn_item(random_number, drop_position, dict_slot_data, dict_item_data, item_data_scene)

#func interact() -> void:
	#if interact_ray.is_colliding():
		#var collider : Object = interact_ray.get_collider()
		#if collider:
			#if collider.is_in_group('external_inventory'):
				##collider._player_interact(player_inventory, player_quick_slot)
				#collider.rpc_id(peer_id, "RPC_external_inventory_interact")
			#elif collider.is_in_group('item_interactable'):
				#collider.rpc_id(peer_id, "RPC_give_item", get_path())
				## rpc('delete_item', collider.get_path())
			#elif collider.is_in_group('building_door'):
				#collider._player_interact()

func get_drop_position() -> Vector3:
	var drop_direction : Vector3 = -camera.global_transform.basis.z
	return camera.global_position + drop_direction
	
# func is_inventory_open() -> bool:
# 	return inventory_interface.visible
	
# func give_item(slot_data: InSlotData, drop_item : bool = true) -> bool:
# 	if !player_inventory._pick_up_slot_data(slot_data) \
# 		and !player_quick_slot._pick_up_slot_data(slot_data):
# 		if drop_item: inventory_interface.signal_drop_item.emit(slot_data)
# 		return false
# 	else:
# 		return true
