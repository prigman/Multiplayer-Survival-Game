extends MultiplayerSynchronizer

@export var input_direction : Vector2
@export var direction : Vector3
@export var mouse_sens := 0.15
@export var player : CharacterBody3D
@export var item : Node3D
@export var mesh : MeshInstance3D

@export var cam_rotation : float


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
		#set local inventory data based on server inventory data
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
	
	if Input.is_action_pressed("fire"):
		# 		item.shoot() # todo
		rpc("RPC_shoot")
	if Input.is_action_pressed("right_click"):
		rpc("RPC_scope")
	if item.equiped_item and item._equiped_item_type(item.equiped_item.ItemType.weapon): # если соответствует тип	
		if item.current_time < 1:
			item.apply_recoil(delta)
		# elif player.is_inventory_open() or player.state_machine.is_current_state("Sprint") == true:
		# 	if item.Scoped:
		# 		rpc("RPC_scope")
				

	#### небезопасное действие так как действие может быть не синхронизировано с сервером
	elif item.equiped_item and item._equiped_item_type(item.equiped_item.ItemType.building):
		if !player.is_inventory_open(): # проверка если закрыт инвентарь
			item.call_deferred("check_place_for_building")
			if item.building_scene.is_able_to_build and Input.is_action_just_pressed("fire"): # ожидается нажатие на ЛКМ для установки постройки
				# place_building_part(building_scene, _collider_interacted_path)
				rpc_id(1, "RPC_place_building", item.building_scene.global_transform.origin, item.collider_interacted_path)
		else:
			if item.building_scene.visible: item.building_scene.call_deferred("hide")
	####

func _process(delta: float) -> void:
	var velocity_string := "%.2f" % player.velocity.length()
	player.debug_ui.add_property("velocity", velocity_string, + 1)
	if item.RPC_is_item_equiped:
		weapon_tilt(input_direction.x, delta)
		weapon_sway(delta)
		weapon_bob(player.velocity.length(), delta)

# ------------ Player states

func update_gravity(delta : float) -> void:
	if not player.is_on_floor():
		player.velocity.y -= player.gravity * delta
	
func update_input(speed : float, acceleration : float, decceleration : float) -> void:

	input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	direction = camera_controller.transform.basis * Vector3(input_direction.x, 0, input_direction.y).normalized()
	if direction:
		player.velocity.x = lerp(player.velocity.x, direction.x * speed, acceleration)
		player.velocity.z = lerp(player.velocity.z, direction.z * speed, acceleration)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, decceleration)
		player.velocity.z = move_toward(player.velocity.z, 0, decceleration)
	
	# if player.RPC_play_sound:
	if player.is_on_floor():
		play_footsteps_sound()

func update_velocity() -> void:
	player.move_and_slide()


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

	if event is InputEventMouseMotion and !player.is_inventory_open():
		# rpc_id(1,"RPC_rotate_player", deg_to_rad( - event.relative.x * mouse_sens))
		# player.rotate_y(deg_to_rad( - event.relative.x * mouse_sens))
		camera_controller.rotate_y(deg_to_rad( - event.relative.x * mouse_sens))
		cam_rotation = camera_controller.rotation.y
		camera_holder.rotate_x(deg_to_rad( - event.relative.y * mouse_sens))
		camera_holder.rotation.x = clamp(camera_holder.rotation.x, deg_to_rad( - 85), deg_to_rad(85))
		mouse_input = event.relative
		item.raycasts_controller.rotation = camera_controller.rotation 
		# Отправляем данные на сервер с помощью RPC
		# rpc("sync_rotation", player.rotation.y)


# Этот метод будет вызываться на сервере
# @rpc("any_peer", "call_local", "unreliable", 0)
# func sync_rotation(rot: float) -> void:
	# if is_multiplayer_authority(): return
	# player.rotation.y = rot

# @rpc("any_peer", "call_local", "unreliable", 0)
# func RPC_rotate_player(rotate_y_delta : float) -> void:
	# player.rotate_y(deg_to_rad( - mouse_input.x * mouse_sens))
	# player.rotate_y(rotate_y_delta)

func _unhandled_input(event : InputEvent) -> void:
	# if not is_multiplayer_authority(): return

	if Input.is_action_just_pressed("quit"):
		# get_tree().quit()
		player.signal_toggle_inventory.emit()
	if event.is_action_pressed("inv_toggle"):
		player.signal_toggle_inventory.emit()
	if event.is_action_pressed("interact"):
		player.interact()

	if event is InputEventKey and event.pressed:
		if not player.is_inventory_open() and item.is_fp_animator_playing() == false: # проверка если закрыт инвентарь
			match event.keycode:
				KEY_1:
					# swap_items(player.player_quick_slot, 0)
					rpc("RPC_swap_items", 0)
				KEY_2:
					# swap_items(player.player_quick_slot, 1)
					rpc("RPC_swap_items", 1)
				KEY_3:
					# swap_items(player.player_quick_slot, 2)
					rpc("RPC_swap_items", 2)
				KEY_4:
					# swap_items(player.player_quick_slot, 3)
					rpc("RPC_swap_items", 3)
				KEY_5:
					# swap_items(player.player_quick_slot, 4)
					rpc("RPC_swap_items", 4)
				KEY_6:
					# swap_items(player.player_quick_slot, 5)
					rpc("RPC_swap_items", 5)
				KEY_0:
					pass
					# if _equiped_item_type(equiped_item.ItemType.weapon):
						# pass
						# toggle_holo_sight() # На кнопку 0 можно переключать меш прицела, если его меш выставлен в ItemDataWeapon для оружия
	if not player.is_inventory_open(): # проверка если закрыт инвентарь
		if Input.is_action_just_pressed("fire"):
			if item.equiped_item and item._equiped_item_type(item.equiped_item.ItemType.tool) and item.is_fp_animator_playing() == false:
				if item.equiped_item.anim_hit and item.equiped_item.anim_player_hit:
					# item.fp_item_animator.play(item.equiped_item.anim_hit)
					# item.fp_player_animator.play(item.equiped_item.anim_player_hit)
					rpc("RPC_play_fp_animations")
			elif item.equiped_item and item._equiped_item_type(item.equiped_item.ItemType.consumable):
				rpc("RPC_use_item")
				# player._on_inventory_interface_signal_use_item(item.equiped_slot)
				# item.remove_item_from_inventory(player.player_quick_slot, item.equiped_slot_index, item.equiped_slot)
		if item.equiped_item and item._equiped_item_type(item.equiped_item.ItemType.weapon) and item.fp_item_animator.current_animation != item.equiped_item.anim_activate and item.fp_item_animator.current_animation != item.equiped_item.anim_reload: # если соответствует тип
			if Input.is_action_just_pressed("reload") and item.equiped_item.ammo_current != item.equiped_item.ammo_max and Input.is_action_pressed("right_click") == false:
				if item.find_ammo_in_inventories()[0]:
					rpc("RPC_reload")
				else:
					print("No ammo to reload in inventories")
			# if Input.is_action_just_released("right_click"):
			# 	if item.Scoped:
			# 		rpc("RPC_reload")
			if Input.is_action_just_pressed("fire"):
				if item.equiped_item.fire_mode_current.mode == WeaponFireModes.FireMode.SINGLE:
					if item.can_shoot(item.equiped_item.fire_mode_current):
						rpc("RPC_single_shot")
			if Input.is_action_just_pressed("change_fire_mode"):
				rpc("RPC_change_fire_mode")

@rpc("any_peer", "call_local", "unreliable", 0)
func RPC_change_fire_mode() -> void:
	for mode : WeaponFireModes in item.equiped_item.fire_modes:
		if mode and mode != item.equiped_item.fire_mode_current:
			item.equiped_item.fire_mode_current = mode
			item.Update_Fire_Mode.emit(item.equiped_item.fire_mode_current)
			break

@rpc("any_peer","call_local", "unreliable_ordered", 1)
func RPC_reload() -> void:
	player.reticle.show()
	player.crosshair.hide()
	item.fp_item_animator.play(item.equiped_item.anim_reload)
	item.fp_player_animator.play(item.equiped_item.anim_player_reload)

@rpc("any_peer", "call_local", "unreliable", 0)
func RPC_use_item() -> void:
	player._on_inventory_interface_signal_use_item(item.equiped_slot)
	item.remove_item_from_inventory(player.player_quick_slot, item.equiped_slot_index, item.equiped_slot)

@rpc("any_peer", "call_local", "unreliable", 0)
func RPC_play_fp_animations() -> void:
	item.fp_item_animator.play(item.equiped_item.anim_hit)
	item.fp_player_animator.play(item.equiped_item.anim_player_hit)

@rpc("any_peer", "call_local", "unreliable", 0)
func RPC_swap_items(key_id : int) -> void:
	# if multiplayer.is_server(): return
	if multiplayer.get_unique_id() == player.peer_id or multiplayer.is_server():
		item.swap_items(player.player_quick_slot, key_id)

@rpc("any_peer", "call_local", "unreliable", 0)
func RPC_shoot() -> void:
	if item.equiped_item and item._equiped_item_type(item.equiped_item.ItemType.weapon): # если соответствует тип
		if !player.is_inventory_open(): # проверка если закрыт инвентарь
			if item.equiped_item.fire_mode_current.mode == WeaponFireModes.FireMode.FULL_AUTO:
				if item.can_shoot(item.equiped_item.fire_mode_current):
					item.shoot()

@rpc("any_peer", "call_local", "reliable", 2)
func RPC_single_shot() -> void:
	item.shoot()

@rpc("any_peer", "call_local", "unreliable", 0)
func RPC_scope() -> void:
	if item.equiped_item and item._equiped_item_type(item.equiped_item.ItemType.weapon): # если соответствует тип
		if !player.is_inventory_open(): # проверка если закрыт инвентарь
			if player.state_machine.is_current_state("Sprint") == false:
				if item.fp_item_animator.current_animation != item.equiped_item.anim_reload and item.fp_item_animator.current_animation != item.equiped_item.anim_activate:
					item.Assault_Rifle_Scope()
		elif player.is_inventory_open() or player.state_machine.is_current_state("Sprint") == true:
			item.Assault_Rifle_Scope()

@rpc("any_peer", "call_local", "reliable", 2)
func RPC_place_building(position : Vector3, collider_path : String) -> void:
	item.place_building_part(position, collider_path)