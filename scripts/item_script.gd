class_name ItemScript extends Node3D

signal Update_Ammo
signal Update_Fire_Mode(fire_mode: WeaponFireModes)

const HIT_DECAL := preload("res://scenes/shoot_decal.tscn")

# все предметы, которые можно взять в руки
@export var fp_items_array: Array[Node3D]

# tree
@export var rig_holder: Node3D
@export var fp_player_node: Node3D
@export var fp_player_animator: AnimationPlayer
var fp_item_animator: AnimationPlayer
@export var camera_holder: Node3D
@export var player: CharacterBody3D
@export var state_machine: StateMachine
@export var timer: Timer
#

# ui
@export var weapon_hud: VBoxContainer
@export var reticle: CenterContainer # перекрестие и точка
@export var crosshair: Control # только перекрестие
#

# raycasts
@export var aim_cast: RayCast3D
@export var melee_cast: RayCast3D
@export var building_cast: RayCast3D
@export var other_buildings_cast : RayCast3D
#

@export var audio_queue : Node3D

# информация о предмете в руках в данный момент
var equiped_item_node: Node3D = null # нода оружия (для того чтобы не проходится по массиву каждый раз)
var equiped_slot: InSlotData = null # слот, который в данный момент выбран
var equiped_item: ItemData = null # айтем в этом слоте (для удобства, так как айтем можно получить через equiped_slot.item)
var equiped_slot_index: int # индекс equip слота нужен для переключения активного слота
#

# для оружия
var Scoped := false
var toggle_holo := false # переключение прицела
var toggle_silencer := false # переключение глушителя
#

# отдача оружия
var def_pos_holder_z: float
var def_holder_pos: Vector3
var def_pos_sight: Vector3
var def_pos: Vector3
var def_rot: Vector3
var target_rot: Vector3
var target_pos: Vector3
var current_time: float
#

# building system
var building_scene : StaticBody3D # хранит в себе сцену со строительным объектом
var wrong_colliders : Array[Area3D]

func _physics_process(delta : float) -> void:
	if not is_multiplayer_authority():
		return
	if _equiped_item_type(equiped_item.ItemType.weapon): # если соответствует тип
		if !player.is_inventory_open(): # проверка если закрыт инвентарь
			if Input.is_action_pressed("fire"):
				if equiped_item.fire_mode_current.mode == WeaponFireModes.FireMode.FULL_AUTO:
					if can_shoot(equiped_item.fire_mode_current):
						shoot()
			if Input.is_action_pressed("right_click"):
				if state_machine.is_current_state("Sprint") == false:
					if !Scoped and fp_item_animator.current_animation != equiped_item.anim_reload and fp_item_animator.current_animation != equiped_item.anim_activate:
						Assault_Rifle_Scope()
						reticle.hide()
						crosshair.hide()
		if current_time < 1:
			apply_recoil(delta)
		elif player.is_inventory_open() or state_machine.is_current_state("Sprint") == true:
			if Scoped:
				crosshair.show()
				Assault_Rifle_Scope()
				
	elif _equiped_item_type(equiped_item.ItemType.building):
		if !player.is_inventory_open(): # проверка если закрыт инвентарь
			call_deferred("check_place_for_building")
		else:
			if building_scene.visible: building_scene.call_deferred("hide")
	
	
			
		
func _unhandled_input(event : InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	if event is InputEventKey and event.pressed:
		if !player.is_inventory_open() and is_fp_animator_playing() == false: # проверка если закрыт инвентарь
			match event.keycode:
				KEY_1:
					swap_items(player.player_quick_slot, 0)
				KEY_2:
					swap_items(player.player_quick_slot, 1)
				KEY_3:
					swap_items(player.player_quick_slot, 2)
				KEY_4:
					swap_items(player.player_quick_slot, 3)
				KEY_5:
					swap_items(player.player_quick_slot, 4)
				KEY_6:
					swap_items(player.player_quick_slot, 5)
				KEY_0:
					if _equiped_item_type(equiped_item.ItemType.weapon):
						pass
						# toggle_holo_sight() # На кнопку 0 можно переключать меш прицела, если его меш выставлен в ItemDataWeapon для оружия
	
	if !player.is_inventory_open(): # проверка если закрыт инвентарь
		if Input.is_action_just_pressed("fire"):
			if _equiped_item_type(equiped_item.ItemType.tool ) and is_fp_animator_playing() == false:
				if equiped_item.anim_hit and equiped_item.anim_player_hit:
					fp_item_animator.play(equiped_item.anim_hit)
					fp_player_animator.play(equiped_item.anim_player_hit)
			elif _equiped_item_type(equiped_item.ItemType.consumable): 
				player._on_inventory_interface_signal_use_item(equiped_slot)
				remove_item_from_inventory(player.player_quick_slot, equiped_slot_index, equiped_slot)

		if _equiped_item_type(equiped_item.ItemType.weapon) and fp_item_animator.current_animation != equiped_item.anim_activate and fp_item_animator.current_animation != equiped_item.anim_reload: # если соответствует тип
			if Input.is_action_just_pressed("reload") and equiped_item.ammo_current != equiped_item.ammo_max and Input.is_action_pressed("right_click") == false:
				if find_ammo_in_inventories()[0]:
					reticle.show()
					crosshair.hide()
					fp_item_animator.play(equiped_item.anim_reload)
					fp_player_animator.play(equiped_item.anim_player_reload)
				else:
					print("No ammo to reload in inventories")
			if Input.is_action_just_released("right_click"):
				if Scoped:
					Assault_Rifle_Scope()
					reticle.hide()
					crosshair.show()
			if Input.is_action_just_pressed("fire"):
				if equiped_item.fire_mode_current.mode == WeaponFireModes.FireMode.SINGLE:
					if can_shoot(equiped_item.fire_mode_current):
						shoot()
			if Input.is_action_just_pressed("change_fire_mode"):
				for mode : WeaponFireModes in equiped_item.fire_modes:
					if mode and mode != equiped_item.fire_mode_current:
						equiped_item.fire_mode_current = mode
						Update_Fire_Mode.emit(equiped_item.fire_mode_current)
						break

func check_place_for_building() -> void:
	if building_scene and building_cast and other_buildings_cast:
		building_change_visibility(false)
		if building_scene.item_data.building_type == building_scene.item_data.BuildingType.inventory: # для строений типа инвентарь
			var is_raycast_colliding := other_buildings_cast.is_colliding()
			if is_raycast_colliding: # если луч попадает на одну из заданных поверхностей - код выполняется, в ином случае постройка скрывается
				var collision_point := other_buildings_cast.get_collision_point()
				building_change_visibility(true)
				building_scene.global_transform.origin = Vector3(collision_point.x, collision_point.y, collision_point.z)
		else: # остальные строения

			var is_raycast_colliding := building_cast.is_colliding()
			var collider_interacted := building_cast.get_collider()
			if is_raycast_colliding: # если луч попадает на одну из заданных поверхностей - код выполняется, в ином случае постройка скрывается
				var collision_point := building_cast.get_collision_point() # точка столкновения луча с коллизией
				if collider_interacted:
					if collider_interacted.is_in_group('building_collider'): # если луч касается коллайдера в котором размещается постройка
						if collider_interacted.collider_type == building_scene.item_data.building_type: # если тип коллайдера, в котором размещается постройка, равен типу самой постройки - устанавливается в позицию
							building_change_visibility(true) # переключение видимости постройки, если true - сделать видимой
							building_scene.global_transform.origin = collider_interacted.global_transform.origin
							building_scene.global_rotation_degrees.y = collider_interacted.global_rotation_degrees.y
						else:
							for collider : Area3D in collider_interacted.get_parent().building_colliders: # тут нужно отключить и запомнить все коллайдеры, которые не равны типу постройки в данный момент, это для того чтобы луч не взаимодействовал с лишними
								if collider and collider.collider_type != building_scene.item_data.building_type:
									collider.get_child(0).disabled = true
									wrong_colliders.append(collider)
				elif not collider_interacted and building_scene.item_data.building_type == building_scene.item_data.BuildingType.floor:
					building_change_visibility(true) # переключение видимости постройки, если true - сделать видимой
					building_scene.global_transform.origin = Vector3(collision_point.x, collision_point.y, collision_point.z)
					building_scene.rotation_degrees.y = 0
		if not building_scene.shape_cast.is_colliding() and not building_scene.building_collision.has_overlapping_bodies(): # остальные проверки для успешной установки
				building_set_possibility_to_place(building_scene, true)
		else:
			building_set_possibility_to_place(building_scene, false)
		if building_scene.is_able_to_build and Input.is_action_just_pressed("fire"): # ожидается нажатие на ЛКМ для установки постройки
			place_building_part(building_scene)

func building_set_possibility_to_place(building : StaticBody3D, possibility : bool) -> void:
	if possibility:
		building.is_able_to_build = true
		building.mesh_node.set_surface_override_material(0, building.TRUE_MATERIAL)
	else:
		building.is_able_to_build = false
		building.mesh_node.set_surface_override_material(0, building.FALSE_MATERIAL)

func building_change_visibility(visibility : bool) -> void:
	if not visibility and building_scene.visible: building_scene.hide()
	elif visibility and not building_scene.visible: building_scene.show()

func place_building_part(_building_scene : StaticBody3D) -> void:
	var building_scene_path : String = equiped_item.dictionary["scene_path"]
	remove_item_from_inventory(player.player_quick_slot, equiped_slot_index, equiped_slot) # убирает из рук предмет
	rpc("spawn_building_part", building_scene_path, _building_scene.global_position.x, _building_scene.global_position.y, _building_scene.global_position.z, _building_scene.global_rotation_degrees.y, player.peer_id) # посылаем на сервер запрос на спавн постройки

@rpc("any_peer", "reliable", "call_local")
func spawn_building_part(building_scene_path : String, position_x : float, position_y : float, position_z : float, rotation_y : float, player_id : int) -> void:
	if not multiplayer.is_server(): return
	print("SERVER: player spawned building")
	var building_instance : StaticBody3D = load(building_scene_path).instantiate()
	get_tree().get_first_node_in_group("world").call_deferred("add_child", building_instance, true) # добавляет постройку в обычный мир
	call_deferred("set_building_data", building_instance, position_x, position_y, position_z, rotation_y, player_id)

func set_building_data(building_instance : StaticBody3D, position_x : float, position_y : float, position_z : float, rotation_y : float, player_id : int) -> void:
	if building_instance.item_data.building_type == building_instance.item_data.BuildingType.inventory:
		rpc("send_rpc_to_add_to_external_inventory", building_instance.name)
		# building_instance.signal_building_spawn.emit(player)
	else:
		for instance_collider : Area3D in building_instance.building_colliders: # включение коллайдеров постройки к которым она может крепиться
			if instance_collider: instance_collider.get_child(0).disabled = false
	building_instance.building_part_owner_id = player_id # айди владельца постройки
	building_instance.global_transform.origin = Vector3(position_x, position_y, position_z)
	building_instance.global_rotation_degrees.y = rotation_y
	#building_set_material(building_instance, building_instance.DEFAULT_MATERIAL)
	building_instance.shape_cast.enabled = false # отключение шейпкаста, который проверяет на столкновения постройки с определёнными игровыми объектами в мире во время выполнения функции check_place_for_building
	building_instance.collision_shape.disabled = false # включение коллизии постройки
	building_instance.building_collision.get_child(0).disabled = true # отключение коллизии, которая проверяет столкновения с уже установленными мешами построек (эта коллизия используется во время выполнения функции check_place_for_building)
	building_instance.mesh_node.cast_shadow = 1
	var building_data : Dictionary = {
		"building_name": building_instance.name,
		"building_position": building_instance.global_transform.origin
	}
	rpc_id(player_id, "add_building_in_own", building_data) # записываем игроку данные о его постройке

@rpc("any_peer", "reliable", "call_local")
func send_rpc_to_add_to_external_inventory(external_inventory : String) -> void:
	player.connect_external_inventory_signal_to_player(external_inventory)
	

@rpc("any_peer", "reliable", "call_local")
func add_building_in_own(building_data : Dictionary) -> void:
	player.buildings_in_own.append(building_data)

func initialize(inventory_data: InventoryData, slot_index: int, item_slot: InSlotData) -> void: # создаем либо свапаем предмет в руках / принимаем данные из item_slot и назначаем меш предмета
	if not is_multiplayer_authority(): return
	if item_slot == null: return
	clear_animations() # очистка анимации предмета если проигрывается в данный момент
	clear_building()
	inventory_data.signal_update_active_slot.emit(inventory_data, slot_index, equiped_slot_index, item_slot, equiped_slot) # сигнал инвентарю быстрого доступа обновить активность данному слоту
	#-назначаем основные переменные этого класса
	equiped_slot = item_slot
	equiped_item = equiped_slot.item
	equiped_slot_index = slot_index
	#-
	if _equiped_item_type(equiped_item.ItemType.weapon) == false:
		clear_weapon_hud() # прячем UI оружия (clear_weapon)
	if equiped_item_node:
		if equiped_item_node.visible:
			equiped_item_node.hide()
		equiped_item_node = null
	for item_node in fp_items_array: # все отображаемое оружие в руках находится в этом массиве
		if item_node and item_node.item_name == equiped_item.name:
			if !fp_player_node.visible: # если нода модельки рук скрыта, отображаем ее
				fp_player_node.show()
			equiped_item_node = item_node
			fp_item_animator = equiped_item_node.animator
			fp_player_animator.play(equiped_item.anim_player_activate)
			fp_item_animator.play(equiped_item.anim_activate)
			item_node.show()
			break
	if !equiped_item_node:
		if fp_player_node.visible:
			fp_player_node.hide()
	if _equiped_item_type(equiped_item.ItemType.weapon) or _equiped_item_type(equiped_item.ItemType.tool):
		fp_item_animator.play(equiped_item.anim_activate)
		fp_player_animator.play(equiped_item.anim_player_activate)
	if _equiped_item_type(equiped_item.ItemType.weapon):
		for data : PlayerWeaponSpread in player.weapon_spread_data:
			if data and data.weapon_data.name == equiped_item.name:
				player.current_weapon_spread_data = data # выставляется ресурс с данными о разбросе для оружия
				break
		weapon_hud.show()
		crosshair.show()
		reticle.hide()
		Update_Ammo.emit(equiped_item.ammo_current)
		Update_Fire_Mode.emit(equiped_item.fire_mode_current)
		update_pos() # получение первоначальной позиции для разброса во время стрельбы
		#set_weapon_attachments() # добавляются либо удаляются обвесы на оружие
	elif _equiped_item_type(equiped_item.ItemType.building):
		if equiped_item.dictionary.has("scene_path"):
			var path := load(equiped_item.dictionary["scene_path"])
			building_scene = path.instantiate()
			player.call_deferred("add_child", building_scene)
					#building_scene.mesh_building.mesh = equiped_item.mesh
					# в process выставляется позиция для building_scene

func clear_item(inventory_data : InventoryData, index : int, slot_data : InSlotData) -> void:
	if not is_multiplayer_authority():
			return

	if fp_player_node.visible:
		fp_player_node.hide()
	if equiped_item_node:
		equiped_item_node.hide()

	clear_animations() # очистка анимации предмета если проигрывается в данный момент
	
	clear_building()

	inventory_data.signal_update_active_slot.emit(inventory_data, index, equiped_slot_index, slot_data, equiped_slot) #  сигнал инвентарю быстрого доступа обновить активность данному слоту

	if _equiped_item_type(equiped_item.ItemType.weapon):
		clear_weapon()

	equiped_slot = null
	equiped_item = null
	equiped_item_node = null

func clear_weapon() -> void:
	clear_weapon_attachments() # очищаем меш прицела если он не null
	clear_weapon_hud() # убираем перекрестие и hud
	#player.current_weapon_spread_data = null

func clear_building() -> void:
	if _equiped_item_type(equiped_item.ItemType.building):
		if wrong_colliders:
			for collider in wrong_colliders:
				if collider:
					collider.get_child(0).disabled = false
			wrong_colliders = []
		if building_scene:
			building_scene.queue_free()
			building_scene = null
	
func clear_animations() -> void:
	if fp_player_animator and fp_player_animator.is_playing():
		fp_player_animator.stop()
	if fp_item_animator and fp_item_animator.is_playing():
		fp_item_animator.stop()
	if Scoped:
		Scoped = false

func is_fp_animator_playing() -> bool:
	if not is_multiplayer_authority():
		pass
	if fp_player_animator and fp_player_animator.is_playing():
		return true
	if fp_item_animator and fp_item_animator.is_playing():
		return true
	else:
		return false

func apply_recoil(delta : float) -> void:
	if not is_multiplayer_authority():
		return
	current_time += delta
	var recoil_speed : float = current_time * equiped_item.recoil_speed
	rig_holder.position.z = lerp(rig_holder.position.z, def_pos_holder_z + target_pos.z, equiped_item.lerp_speed * delta)
	rig_holder.rotation.z = lerp(rig_holder.rotation.z, def_rot.z - target_rot.z, equiped_item.lerp_speed * delta)
	rig_holder.rotation.x = lerp(rig_holder.rotation.x, def_rot.x - target_rot.x, equiped_item.lerp_speed * delta)
	camera_holder.rotation.x = lerp(camera_holder.rotation.x, camera_holder.rotation.x + equiped_item.recoil_rotation_z.sample(current_time) * equiped_item.recoil_amplitude.y, equiped_item.lerp_speed * delta)
	camera_holder.rotation.x = clamp(camera_holder.rotation.x, deg_to_rad( - 85), deg_to_rad(85))
	player.rotation.y = lerp(player.rotation.y, player.rotation.y + equiped_item.recoil_rotation_x.sample(current_time) * equiped_item.recoil_amplitude.x, equiped_item.lerp_speed * delta)
	target_pos.z = equiped_item.recoil_position_z.sample(recoil_speed) * equiped_item.recoil_amplitude.z
	target_rot.z = equiped_item.recoil_rotation_z.sample(recoil_speed) * equiped_item.recoil_amplitude.x
	target_rot.x = equiped_item.recoil_rotation_x.sample(recoil_speed) * - equiped_item.recoil_amplitude.y

func shoot() -> void:
	if not is_multiplayer_authority():
		return
	#audio_queue.play_sound()
	rpc("play_shoot_sound")
	randomize_aimcast_spread()
	hitscan(aim_cast)
	update_weapon_ammo( - 1) # отнимаем current ammo и обновляем худ
	equiped_item.recoil_amplitude.x *= - 1 if randf() > 0.75 else 1
	target_pos.z = equiped_item.recoil_position_z.sample(0) * equiped_item.recoil_amplitude.z
	target_rot.z = equiped_item.recoil_rotation_z.sample(0) * equiped_item.recoil_amplitude.x / 1.5
	target_rot.x = equiped_item.recoil_rotation_x.sample(0) * equiped_item.recoil_amplitude.y / 2
	current_time = 0

@rpc("any_peer","unreliable","call_local")
func play_shoot_sound() -> void:
	audio_queue.play_sound()

func update_pos() -> void:
	if not is_multiplayer_authority():
		return
	def_pos = rig_holder.position
	def_rot = rig_holder.rotation
	target_rot.y = 0.0
	current_time = 1
	
func hitscan(raycast: RayCast3D) -> void:
	if not is_multiplayer_authority():
		return
	raycast.force_raycast_update()
	var target : Object = raycast.get_collider()
	var ray_end_point : Vector3 = raycast.get_collision_point()
	if ray_end_point:
		var decal := HIT_DECAL.instantiate()
		if target:
			target.call_deferred("add_child", decal)
			player_hit(target)
			if raycast == melee_cast and equiped_item.ItemType.tool:
				if target.is_in_group("world_resource"):
					if equiped_item.tool_type == equiped_item.ToolType.pickaxe and target.is_in_group("stone_object"):
						target.health -= randf_range(equiped_item.damage, equiped_item.damage * 2)
						create_player_item(load("res://inventory/item/objects/resource_stone.tres"), randi_range(2, 6))
					if equiped_item.tool_type == equiped_item.ToolType.axe and target.is_in_group("pine_tree_object"):
						target.health -= randf_range(equiped_item.damage, equiped_item.damage * 2)
						create_player_item(load("res://inventory/item/objects/resource_pine_wood.tres"), randi_range(2, 6))
				if target.is_in_group("enemy_group"):
					target.health -= equiped_item.damage
		else:
			player.main_scene.call_deferred("add_child", decal)
		call_deferred("shoot_decal_instance", ray_end_point, decal, raycast)

func shoot_decal_instance(ray_end_point : Vector3, decal : Node, raycast : RayCast3D) -> void:
	decal.global_transform.origin = ray_end_point
	var side: Vector3
	if raycast.get_collision_normal() == Vector3.UP:
		side = Vector3(1, 0, 0)
	elif raycast.get_collision_normal() == Vector3.DOWN:
		side = Vector3( - 1, 0, 0)
	else:
		side = Vector3(0, 1, 0)
	decal.look_at(ray_end_point + raycast.get_collision_normal(), side)

func player_hit(target : Object)->void:
	if target.is_in_group("player"):
		target.rpc('died_process',equiped_item.damage)
		print("EnemyP_health:", target.health_value)

func randomize_aimcast_spread() -> void:
	var rng := RandomNumberGenerator.new()
	var crosshair_width : float = reticle.crosshair_range
	var crosshair_height : float = reticle.crosshair_range
	var raycast_length_ignore_value : float = aim_cast.target_position.z / 100.0 # 100 - это стандартное значение, при котором разброс адекватен
	# Генерация случайных координат внутри квадрата
	var randomize_spread_x : float = rng.randf_range(-crosshair_width / 2, crosshair_width / 2) * raycast_length_ignore_value
	var randomize_spread_y : float = rng.randf_range(-crosshair_height / 2, crosshair_height / 2) * raycast_length_ignore_value
	aim_cast.target_position.x = randomize_spread_x
	aim_cast.target_position.y = randomize_spread_y

func Assault_Rifle_Scope() -> void:
	if !Scoped:
		fp_item_animator.play(equiped_item.anim_scope)
		fp_player_animator.play(equiped_item.anim_player_scope)
	else:
		fp_item_animator.play_backwards(equiped_item.anim_scope)
		fp_player_animator.play_backwards(equiped_item.anim_player_scope)
	Scoped = !Scoped
	
func toggle_holo_sight() -> void:
	if equiped_item.sight_mesh != null and equiped_item.muzzle_mesh != null:
		toggle_holo = !toggle_holo
		toggle_silencer = !toggle_silencer
		if !toggle_silencer:
			#silencer.mesh = equiped_item.muzzle_mesh
			pass
		if !toggle_holo:
			#holo.mesh = equiped_item.sight_mesh
			pass
		else:
			#holo.mesh = null
			#silencer.mesh = null
			pass

func set_weapon_attachments() -> void:
	if equiped_item.sight_mesh:
		#holo.mesh = equiped_item.sight_mesh
		pass
	if equiped_item.muzzle_mesh:
		#silencer.mesh = equiped_item.muzzle_mesh
		pass
	else:
		clear_weapon_attachments()

func clear_weapon_attachments() -> void:
	#if holo.mesh:
		#holo.mesh = null
	#if silencer.mesh:
		#silencer.mesh = null
		pass

func clear_weapon_hud() -> void:
	if weapon_hud.visible:
		weapon_hud.hide()
	if crosshair.visible: # разделение перекрестия и точки
		crosshair.hide()
	reticle.show()

func reload() -> void:
	if not is_multiplayer_authority():
		return
	reticle.hide()
	crosshair.show()
	var ammo_to_reload : int
	var data : Array = find_ammo_in_inventories()
	var ammo_slots : Array[InSlotData] = data[0]
	var is_inventory : bool = data[1]
	var is_quick_slot : bool = data[2]
	for ammo_slot in ammo_slots:
		if ammo_slot and ammo_slot.amount_in_slot >= 1:
			ammo_to_reload = min(ammo_slot.amount_in_slot, equiped_item.ammo_max - equiped_item.ammo_current)
			ammo_slot.amount_in_slot -= ammo_to_reload
			equiped_item.ammo_current += ammo_to_reload
	Update_Ammo.emit(equiped_item.ammo_current)
	if is_inventory:
		player.player_inventory._update_inventory()
	elif is_quick_slot:
		player.player_quick_slot._update_inventory()

func update_weapon_ammo(value: int) -> void:
	equiped_item.ammo_current += value
	Update_Ammo.emit(equiped_item.ammo_current)

func find_ammo_in_inventories() -> Array:
	if !player.player_inventory or !player.player_quick_slot:
		return []
	var ammo_data: Array[InSlotData]
	var is_inventory : bool
	var is_quick_slot : bool
	
	for slot : InSlotData in player.player_inventory.slots_data:
		if slot and slot.item.item_type == slot.item.ItemType.ammo and slot.item.weapon_type == equiped_item.weapon_type and slot.amount_in_slot >= 1:
			is_inventory = true
			ammo_data.append(slot)

	for slot : InSlotData in player.player_quick_slot.slots_data:
		if slot and slot.item.item_type == slot.item.ItemType.ammo and slot.item.weapon_type == equiped_item.weapon_type and slot.amount_in_slot >= 1:
			is_quick_slot = true
			ammo_data.append(slot)

	return [ammo_data, is_inventory, is_quick_slot]

func swap_items(inventory_data: InventoryData, index: int) -> void:
	if not is_multiplayer_authority():
		return
	var slot_data := inventory_data.slots_data[index]
	for i in index + 1:
		match [slot_data, equiped_slot, index]:
			[null, null, i]:
				print("Niche nety v rykah i slot pystoi")
				inventory_data.signal_update_active_slot.emit(inventory_data, index, equiped_slot_index, slot_data, equiped_slot)
				break
			[null, _, i]:
				print("Item removed")
				clear_item(inventory_data, index, slot_data)
				break
			[_, null, i]:
				print("Item equiped %s" % slot_data.item.name)
				initialize(inventory_data, index, slot_data)
				break
			[_, _, i]:
				if equiped_slot != slot_data:
					print("Item changed to %s" % slot_data.item.name)
					initialize(inventory_data, index, slot_data)
				else:
					print("Item removed")
					clear_item(inventory_data, index, slot_data)
				break

func _equiped_item_type(equiped_item_type: int) -> bool:
	if equiped_item:
		match equiped_item.item_type:
			equiped_item_type:
				return true
			_:
				return false
	else:
		return false

func can_shoot(fire_mode: WeaponFireModes) -> bool:
	if not is_multiplayer_authority():
		pass
	if player.is_inventory_open() or state_machine.is_current_state("Sprint") \
		or timer.is_stopped() == false or equiped_item.ammo_current == 0 \
		or fp_item_animator.current_animation == equiped_item.anim_reload or fp_item_animator.current_animation == equiped_item.anim_activate:
		return false
	else:
		timer.start(fire_mode.fire_rate)
		return true

func _on_animation_player_pickaxe_animation_finished(anim_name : String) -> void:
	if _equiped_item_type(equiped_item.ItemType.tool ):
		if anim_name == equiped_item.anim_hit:
			fp_item_animator.play(equiped_item.anim_after_hit)
			fp_player_animator.play(equiped_item.anim_player_after_hit)
			hitscan(melee_cast)

func _on_animation_player_m_4_rifle_animation_finished(anim_name : String) -> void:
	if _equiped_item_type(equiped_item.ItemType.weapon):
		if anim_name == equiped_item.anim_reload:
			reload()

func _on_animation_player_axe_animation_finished(anim_name : String) -> void:
	if _equiped_item_type(equiped_item.ItemType. tool ):
		if anim_name == equiped_item.anim_hit:
			fp_item_animator.play(equiped_item.anim_after_hit)
			fp_player_animator.play(equiped_item.anim_player_after_hit)
			hitscan(melee_cast)
			
func create_player_item(item_data: ItemData, amount: int) -> void:
	if not is_multiplayer_authority():
		return
	var slot_data := InSlotData.new()
	slot_data.item = item_data
	slot_data.amount_in_slot = amount
	player.give_item(slot_data)

func remove_item_from_inventory(inventory_data : InventoryData, slot_index : int, slot_data : InSlotData) -> void:
	if not is_multiplayer_authority():
			return
	clear_item(inventory_data, slot_index, slot_data)
	inventory_data._remove_slot_data(slot_index)