extends MultiplayerSynchronizer

@export var input_direction : Vector2
@export var direction : Vector3
@export var mouse_sens := 0.15
@export var player : CharacterBody3D
@export var item : Node3D
@export var mesh : MeshInstance3D

@export var camera_controller_input_rotation_y : float
@export var camera_holder_input_rotation_x : float


@onready var canvas_layer := %CanvasLayer
@onready var camera := %Camera3D
@onready var camera_holder := %CameraHolder
@onready var camera_controller := %CameraController
# @onready var inventory_interface := %InventoryInterface
@onready var label_3d := %Label3D


@export var mouse_input : Vector2

func _ready() -> void:
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		camera.make_current()
		mesh.hide()
		label_3d.hide()
		canvas_layer.show()
		
		# player.signal_toggle_inventory.connect(player._toggle_inventory_interface)
		
		# назначаются данные слотов локальному инвентарю из синхронизированных данных с сервера и создаётся UI слотов
		# inventory_interface._set_interact_player_inventory_data(player.player_inventory)
		# inventory_interface._set_interact_quick_slot_data(player.player_quick_slot)
		
		#
		
		# player.player_inventory.deserialize_inventory_data(player.serialized_player_inventory)
		# player.player_quick_slot.deserialize_inventory_data(player.serialized_player_quick_slot)

		# inventory_interface.player_inventory_ui._set_inventory_data(player.player_inventory)
		# inventory_interface.player_quick_slot_ui._set_inventory_data(player.player_quick_slot)

		# player.player_inventory._update_inventory()
		# player.player_quick_slot._update_inventory()

		#
		
		#inventory_interface._set_player_inventory_data(player.player_inventory)
		#inventory_interface._set_quick_slot_data(player.player_quick_slot)
		# inventory_interface.signal_drop_item.connect(player._on_inventory_interface_signal_drop_item)
		# inventory_interface.signal_use_item.connect(player._on_inventory_interface_signal_use_item)
		#inventory_interface.signal_force_close.connect(player._toggle_inventory_interface)
		
		# for node in get_tree().get_nodes_in_group("external_inventory"):
		# 	if node: node.signal_toggle_inventory.connect(player._toggle_inventory_interface)
	else:
		camera.clear_current()
		set_process_for_player(false)

func set_process_for_player(value : bool) -> void:
	set_process(value)
	set_physics_process(value)
	set_process_input(value)
	set_process_unhandled_input(value)

func _physics_process(delta : float) -> void:
	# if item.equiped_item and item._equiped_item_type(item.equiped_item.ItemType.weapon):
	# 	player.reticle.adjust_reticle_lines(self)
	# if not is_multiplayer_authority(): return
	input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	#item.raycasts_controller.rotation.x = camera_holder_input_rotation_x
	#item.raycasts_controller.rotation.y = camera_controller_input_rotation_y
	if Input.is_action_pressed("fire") and item.RPC_is_item_equiped:
		# 		item.shoot() # todo
		#rpc("RPC_shoot")
		# if player.is_inventory_open(): return
		if item._equiped_item_type(item.equiped_item.ItemType.weapon): # если соответствует тип
			if item.equiped_item.fire_mode_current.mode == WeaponFireModes.FireMode.FULL_AUTO:
				if item.can_shoot(item.equiped_item.fire_mode_current):
					item.shoot()
	if Input.is_action_pressed("right_click") and item.RPC_is_item_equiped:
		if item._equiped_item_type(item.equiped_item.ItemType.weapon): # если соответствует тип
			# if !player.is_inventory_open(): # проверка если закрыт инвентарь
			if player.state_machine.is_current_state("Sprint") == false:
				if item.fp_item_animator.current_animation != item.equiped_item.anim_reload and item.fp_item_animator.current_animation != item.equiped_item.anim_activate:
					item.Assault_Rifle_Scope()
			elif player.state_machine.is_current_state("Sprint") == true: # player.is_inventory_open()
				item.Assault_Rifle_Scope()
	if item.RPC_is_item_equiped and item._equiped_item_type(item.equiped_item.ItemType.weapon): # если соответствует тип	
		if item.current_time < 1:
			item.apply_recoil(delta)
		# elif player.is_inventory_open() or player.state_machine.is_current_state("Sprint") == true:
		# 	if item.Scoped:
		# 		rpc("RPC_scope")
				

	#### небезопасное действие так как действие может быть не синхронизировано с сервером
	elif item.RPC_is_item_equiped and item.RPC_equiped_slot_index != -1 and item._equiped_item_type(player.player_quick_slot.slots_data[item.RPC_equiped_slot_index].item.ItemType.building):
		item.call_deferred("check_place_for_building")
		if Input.is_action_just_pressed("fire") and item.building_scene.is_able_to_build: # ожидается нажатие на ЛКМ для установки постройки
			rpc_id(1, "RPC_place_building", item.building_scene.global_transform.origin, item.building_scene.global_rotation_degrees.y, item.equiped_item.dictionary["building_scene_path"], item.collider_interacted_path)
	####

func _process(delta: float) -> void:
	var velocity_string := "%.2f" % player.velocity.length()
	player.debug_ui.add_property("velocity", velocity_string, + 1)
	if item.RPC_is_item_equiped:
		weapon_tilt(input_direction.x, delta)
		weapon_sway(delta)
		weapon_bob(player.velocity.length(), delta)
	player.signal_update_player_stats.emit(player.health_value, player.hunger_value)
	if player.is_on_floor():
		play_footsteps_sound()
# ------------ Player states

# func update_gravity(delta : float) -> void:
# 	if not player.is_on_floor():
# 		player.velocity.y -= player.gravity * delta
	
# func update_input(speed : float, acceleration : float, decceleration : float) -> void:

# 	input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
# 	direction = camera_controller.transform.basis * Vector3(input_direction.x, 0, input_direction.y).normalized()
# 	if direction:
# 		player.velocity.x = lerp(player.velocity.x, direction.x * speed, acceleration)
# 		player.velocity.z = lerp(player.velocity.z, direction.z * speed, acceleration)
# 	else:
# 		player.velocity.x = move_toward(player.velocity.x, 0, decceleration)
# 		player.velocity.z = move_toward(player.velocity.z, 0, decceleration)
	
# 	# if player.RPC_play_sound:
# 	if player.is_on_floor():
# 		play_footsteps_sound()

# func update_velocity() -> void:
# 	player.move_and_slide()


#-Camera and weapon tilt
func weapon_tilt(input_x : float, delta : float) -> void:
	if player.weapon_holder:
		player.weapon_holder.rotation.z = lerp(player.weapon_holder.rotation.z, -input_x * player.weapon_rotation_amount * 10, 10 * delta)

func weapon_sway(delta : float) -> void:
	mouse_input = lerp(mouse_input, Vector2.ZERO, 10 * delta)
	player.weapon_holder.rotation.x = lerp(player.weapon_holder.rotation.x, mouse_input.y * player.weapon_rotation_amount * ( - 1 if player.invert_weapon_sway else 1), 10 * delta)
	player.weapon_holder.rotation.y = lerp(player.weapon_holder.rotation.y, mouse_input.x * player.weapon_rotation_amount * ( - 1 if player.invert_weapon_sway else 1), 10 * delta)
	
func weapon_bob(vel: float, delta : float) -> void:
	if player.weapon_holder:
		if vel > 0 and player.is_on_floor() and !item.Scoped:
			var bob_amount: float = 0.01
			var bob_freq: float = 0.01
			player.weapon_holder.position.y = lerp(player.weapon_holder.position.y, player.def_weapon_holder_pos.y + sin(Time.get_ticks_msec() * bob_freq) * bob_amount, 10 * delta)
			player.weapon_holder.position.x = lerp(player.weapon_holder.position.x, player.def_weapon_holder_pos.x + sin(Time.get_ticks_msec() * bob_freq * 0.5) * bob_amount, 10 * delta)
			
		else:
			player.weapon_holder.position.y = lerp(player.weapon_holder.position.y, player.def_weapon_holder_pos.y, 10 * delta)
			player.weapon_holder.position.x = lerp(player.weapon_holder.position.x, player.def_weapon_holder_pos.x, 10 * delta)
#-------

# @rpc("any_peer", "call_local", "unreliable", 0)
# func RPC_move_player(velocity : Vector3) -> void:
# 	player.velocity = velocity
# 	player.move_and_slide()

func play_footsteps_sound() -> void:
	# print("play_sound")
	var current_position_x := player.global_transform.origin.x
	var current_position_z := player.global_transform.origin.z

	player.distance_travelled_x += abs(current_position_x - player.last_position_x)
	player.distance_travelled_z += abs(current_position_z - player.last_position_z)

	player.last_position_x = current_position_x
	player.last_position_z = current_position_z

	if player.distance_travelled_x >= 1.5 or player.distance_travelled_z >= 1.5:
		player.distance_travelled_x = 0.0
		player.distance_travelled_z = 0.0
		player.sound_footstep_pool.play_random_sound()

# @rpc("any_peer", "unreliable", "call_local", 0)
# func RPC_play_footsteps_sound() -> void:
# 	# if is_multiplayer_authority(): return
# 	player.sound_footstep_pool.play_random_sound()

func _input(event : InputEvent) -> void:
	# if not is_multiplayer_authority(): return

	if event is InputEventMouseMotion: # and !player.is_inventory_open():
		# rpc_id(1,"RPC_rotate_player", deg_to_rad( - event.relative.x * mouse_sens))
		# player.rotate_y(deg_to_rad( - event.relative.x * mouse_sens))
		camera_controller.rotate_y(deg_to_rad( - event.relative.x * mouse_sens))
		camera_holder.rotate_x(deg_to_rad( - event.relative.y * mouse_sens))
		camera_holder.rotation.x = clamp(camera_holder.rotation.x, deg_to_rad( - 85), deg_to_rad(85))
		camera_controller_input_rotation_y = camera_controller.rotation.y
		camera_holder_input_rotation_x = camera_holder.rotation.x
		mouse_input = event.relative
		# item.raycasts_controller.rotation.x = camera_controller.rotation.x

@rpc("any_peer", "call_local", "reliable", 2)
func RPC_button_pressed(button : String, value : bool) -> void:
	match button:
		"left_ctrl":
			player.crouch_button_pressed = value
		"space":
			player.space_button_pressed = value
		"shift":
			player.shift_button_pressed = value

func _unhandled_input(event : InputEvent) -> void:
	if Input.is_action_pressed("left_ctrl"):
		rpc_id(1,"RPC_button_pressed", "left_ctrl", true)
	if Input.is_action_just_released("left_ctrl"):
		rpc_id(1,"RPC_button_pressed", "left_ctrl", false)
	if Input.is_action_just_pressed("space"):
		rpc_id(1,"RPC_button_pressed", "space", true)
	if Input.is_action_just_released("space"):
		rpc_id(1,"RPC_button_pressed", "space", false)
	if Input.is_action_pressed("shift"):
		rpc_id(1,"RPC_button_pressed", "shift", true)
	if Input.is_action_just_released("shift"):
		rpc_id(1,"RPC_button_pressed", "shift", false)
	# if Input.is_action_just_pressed("quit"):
		# player.signal_toggle_inventory.emit()
	# if event.is_action_pressed("inv_toggle"):
	# 	player.signal_toggle_inventory.emit()
	# if event.is_action_pressed("interact"):
	# 	local_interact()
		#rpc_id(1,"RPC_interact")

	# if event is InputEventKey and event.pressed:
	# 	if player.is_inventory_open() and item.is_fp_animator_playing(): return
	# 	match event.keycode:
	# 		KEY_1:
	# 			rpc_id(1,"RPC_swap_items", 0, player.peer_id)
	# 		KEY_2:
	# 			rpc_id(1,"RPC_swap_items", 1, player.peer_id)
	# 		KEY_3:
	# 			rpc_id(1,"RPC_swap_items", 2, player.peer_id)
	# 		KEY_4:
	# 			rpc_id(1,"RPC_swap_items", 3, player.peer_id)
	# 		KEY_5:
	# 			rpc_id(1,"RPC_swap_items", 4, player.peer_id)
	# 		KEY_6:
	# 			rpc_id(1,"RPC_swap_items", 5, player.peer_id)
	# 		KEY_0:
	# 			pass
					# if _equiped_item_type(equiped_item.ItemType.weapon):
						# pass
						# toggle_holo_sight() # На кнопку 0 можно переключать меш прицела, если его меш выставлен в ItemDataWeapon для оружия

	if Input.is_action_just_pressed("reload") and item.RPC_is_item_equiped:
		#rpc("RPC_reload")
		# if player.is_inventory_open(): return
		if not item.Scoped:
			if item._equiped_item_type(item.equiped_item.ItemType.weapon) and item.fp_item_animator.current_animation != item.equiped_item.anim_activate and item.fp_item_animator.current_animation != item.equiped_item.anim_reload: # если соответствует тип
				if item.equiped_item.ammo_current != item.equiped_item.ammo_max:
					if item.find_ammo_in_inventories()[0]:
						item.start_reload()
					else:
						print("No ammo to reload in inventories")
	if Input.is_action_just_pressed("fire") and item.RPC_is_item_equiped:
		#rpc("RPC_single_shot")
		# if player.is_inventory_open(): return # проверка если закрыт инвентарь
		if item._equiped_item_type(item.equiped_item.ItemType.tool) and item.is_fp_animator_playing() == false:
			if item.equiped_item.anim_hit and item.equiped_item.anim_player_hit:
				item.fp_item_animator.play(item.equiped_item.anim_hit)
				item.fp_player_animator.play(item.equiped_item.anim_player_hit)
		elif item._equiped_item_type(item.equiped_item.ItemType.weapon) and item.fp_item_animator.current_animation != item.equiped_item.anim_activate and item.fp_item_animator.current_animation != item.equiped_item.anim_reload: # если соответствует тип
			if item.equiped_item.fire_mode_current.mode == WeaponFireModes.FireMode.SINGLE:
				if item.can_shoot(item.equiped_item.fire_mode_current):
					item.shoot()
		elif item._equiped_item_type(item.equiped_item.ItemType.tool) and item.is_fp_animator_playing() == false:
			if item.equiped_item.anim_hit and item.equiped_item.anim_player_hit:
				item.fp_item_animator.play(item.equiped_item.anim_hit)
				item.fp_player_animator.play(item.equiped_item.anim_player_hit)
		# elif item._equiped_item_type(item.equiped_item.ItemType.consumable):
		# 	player._on_inventory_interface_signal_use_item(item.equiped_slot)
		# 	item.remove_item_from_inventory(player.player_quick_slot, item.equiped_slot_index, item.equiped_slot)
	if Input.is_action_just_pressed("change_fire_mode") and item.RPC_is_item_equiped:
		#rpc("RPC_change_fire_mode")
		# if player.is_inventory_open(): return
		if item._equiped_item_type(item.equiped_item.ItemType.weapon) and item.fp_item_animator.current_animation != item.equiped_item.anim_activate and item.fp_item_animator.current_animation != item.equiped_item.anim_reload: # если соответствует тип
			for mode : WeaponFireModes in item.equiped_item.fire_modes:
				if mode and mode != item.equiped_item.fire_mode_current:
					item.equiped_item.fire_mode_current = mode
					item.Update_Fire_Mode.emit(item.equiped_item.fire_mode_current)
					break

# @rpc("any_peer", "call_local", "reliable", 2)
# func RPC_interact() -> void:
# 	player.interact()
	
# func local_interact() -> void:
# 	if player.interact_ray.is_colliding():
# 		var collider : Object = player.interact_ray.get_collider()
# 		if collider:
# 			if collider.is_in_group('external_inventory'):
# 				collider._player_interact()
# 				#collider.rpc_id(peer_id, "RPC_external_inventory_interact")
# 			elif collider.is_in_group('item_interactable'):
# 				#collider.rpc_id(peer_id, "RPC_give_item", get_path())
# 				# rpc('delete_item', collider.get_path())
# 				if collider._player_interact(player) == true:
# 					collider.rpc_id(1, 'delete_item')
# 			elif collider.is_in_group('building_door'):
# 				collider._player_interact()

#@rpc("any_peer", "call_local", "unreliable", 0)
#func RPC_change_fire_mode() -> void:
	#if item._equiped_item_type(item.equiped_item.ItemType.weapon) and item.fp_item_animator.current_animation != item.equiped_item.anim_activate and item.fp_item_animator.current_animation != item.equiped_item.anim_reload: # если соответствует тип
		#for mode : WeaponFireModes in item.equiped_item.fire_modes:
			#if mode and mode != item.equiped_item.fire_mode_current:
				#item.equiped_item.fire_mode_current = mode
				#item.Update_Fire_Mode.emit(item.equiped_item.fire_mode_current)
				#break

#@rpc("any_peer","call_local", "reliable", 2)
#func RPC_reload() -> void:
	#if not item.Scoped:
		#if item._equiped_item_type(item.equiped_item.ItemType.weapon) and item.fp_item_animator.current_animation != item.equiped_item.anim_activate and item.fp_item_animator.current_animation != item.equiped_item.anim_reload: # если соответствует тип
			#if item.equiped_item.ammo_current != item.equiped_item.ammo_max:
				#if item.find_ammo_in_inventories()[0]:
					#item.start_reload()
				#else:
					#print("No ammo to reload in inventories")

#@rpc("any_peer", "call_local", "unreliable", 0)
#func RPC_use_item() -> void:
	#player._on_inventory_interface_signal_use_item(item.equiped_slot)
	#item.remove_item_from_inventory(player.player_quick_slot, item.equiped_slot_index, item.equiped_slot)

#@rpc("any_peer", "call_local", "unreliable", 0)
#func RPC_play_fp_animations() -> void:
	#if not player.is_inventory_open(): # проверка если закрыт инвентарь
		#if item.equiped_item and item._equiped_item_type(item.equiped_item.ItemType.tool) and item.is_fp_animator_playing() == false:
			#if item.equiped_item.anim_hit and item.equiped_item.anim_player_hit:
				#item.fp_item_animator.play(item.equiped_item.anim_hit)
				#item.fp_player_animator.play(item.equiped_item.anim_player_hit)

@rpc("any_peer", "call_local", "reliable", 2)
func RPC_swap_items(key_id : int, player_id : int) -> void:
	if multiplayer.is_server() and player.peer_id != player_id: return
	#print("swaped item for server player ", str(player.peer_id))
	# if multiplayer.get_unique_id() == player.peer_id:
	if player.item.RPC_equiped_slot_index == key_id:
		player.item.RPC_equiped_slot_index = -1
	else:
		player.item.RPC_equiped_slot_index = key_id
	rpc_id(player.peer_id, "RPC_set_equiped_item", key_id)
	# elif multiplayer.get_unique_id() == player.peer_id:
		# item.swap_items(player.player_quick_slot, key_id)
	# player.swap_item_button_pressed = number_of_button

@rpc("any_peer", "call_local", "reliable", 2)
func RPC_set_equiped_item(slot_id : int) -> void:
	player.item.swap_items(player.player_quick_slot, slot_id)

#@rpc("any_peer", "call_local", "unreliable", 0)
#func RPC_shoot() -> void:
	#if item.equiped_item and item._equiped_item_type(item.equiped_item.ItemType.weapon): # если соответствует тип
		#if !player.is_inventory_open(): # проверка если закрыт инвентарь
			#if item.equiped_item.fire_mode_current.mode == WeaponFireModes.FireMode.FULL_AUTO:
				#if item.can_shoot(item.equiped_item.fire_mode_current):
					#item.shoot()

#@rpc("any_peer", "call_local", "reliable", 2)
#func RPC_single_shot() -> void:
	#if not player.is_inventory_open(): # проверка если закрыт инвентарь
		#if item._equiped_item_type(item.equiped_item.ItemType.tool) and item.is_fp_animator_playing() == false:
			#if item.equiped_item.anim_hit and item.equiped_item.anim_player_hit:
				#item.fp_item_animator.play(item.equiped_item.anim_hit)
				#item.fp_player_animator.play(item.equiped_item.anim_player_hit)
		#elif item._equiped_item_type(item.equiped_item.ItemType.weapon) and item.fp_item_animator.current_animation != item.equiped_item.anim_activate and item.fp_item_animator.current_animation != item.equiped_item.anim_reload: # если соответствует тип
			#if item.equiped_item.fire_mode_current.mode == WeaponFireModes.FireMode.SINGLE:
				#if item.can_shoot(item.equiped_item.fire_mode_current):
					#item.shoot()
		#elif item._equiped_item_type(item.equiped_item.ItemType.tool) and item.is_fp_animator_playing() == false:
			#if item.equiped_item.anim_hit and item.equiped_item.anim_player_hit:
				#item.fp_item_animator.play(item.equiped_item.anim_hit)
				#item.fp_player_animator.play(item.equiped_item.anim_player_hit)
		#elif item._equiped_item_type(item.equiped_item.ItemType.consumable):
			#player._on_inventory_interface_signal_use_item(item.equiped_slot)
			#item.remove_item_from_inventory(player.player_quick_slot, item.equiped_slot_index, item.equiped_slot)

#@rpc("any_peer", "call_local", "unreliable", 0)
#func RPC_scope() -> void:
	#if item.equiped_item and item._equiped_item_type(item.equiped_item.ItemType.weapon): # если соответствует тип
		#if !player.is_inventory_open(): # проверка если закрыт инвентарь
			#if player.state_machine.is_current_state("Sprint") == false:
				#if item.fp_item_animator.current_animation != item.equiped_item.anim_reload and item.fp_item_animator.current_animation != item.equiped_item.anim_activate:
					#item.Assault_Rifle_Scope()
		#elif player.is_inventory_open() or player.state_machine.is_current_state("Sprint") == true:
			#item.Assault_Rifle_Scope()

@rpc("any_peer", "call_local", "reliable", 2)
func RPC_place_building(building_place_position : Vector3, building_place_rotation_y : float, building_scene_path : String, collided_node_path : NodePath) -> void:
	item.place_building_part(building_place_position, building_place_rotation_y, building_scene_path, collided_node_path)


func _on_button_pressed() -> void:
	rpc_id(1, "request_spawn_player")

@rpc("any_peer", "call_local", "reliable", 2)
func request_spawn_player() -> void:
	player.on_player_respawn()
	
