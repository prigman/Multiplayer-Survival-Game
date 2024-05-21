class_name ItemScript extends Node3D

signal Update_Ammo
signal Update_Fire_Mode(fire_mode : WeaponFireModes)

const BULLET_DECAL = preload("res://scenes/shoot_decal.tscn")

@export var fp_items_array : Array[Node3D]

# items group for fp
@onready var fp_items = $"../fp_player_model2/FP_Items"
@onready var fp_animator = $"../fp_player_model2/AnimationPlayer"
@onready var ar_rifle = $"../fp_player_model2/FP_Items/AR_Rifle"
@onready var fp_player_model = $"../fp_player_model2/fp_player_model"
#

# IK targets for FP
@onready var target_l = $"../fp_player_model2/FP_Items/TargetL"
@onready var target_r = $"../fp_player_model2/FP_Items/TargetR"
#

# ar attachments
@onready var holo = $"../fp_player_model2/FP_Items/AR_Rifle/Attachments/Holo"
@onready var silencer = $"../fp_player_model2/FP_Items/AR_Rifle/Attachments/Silencer"
#

# tree
@export var player : CharacterBody3D
@export var animator : AnimationPlayer
@export var state_machine: StateMachine
@export var camera_holder : Node3D
@export var timer : Timer
#

# ui
@export var weapon_hud: VBoxContainer
@export var reticle: CenterContainer # перекрестие и точка
@export var crosshair: Control # только перекрестие
#

# raycasts
@export var aim_cast : RayCast3D
@export var melee_cast : RayCast3D
@export var building_cast : RayCast3D
@export var building_point : Node3D
#

var equiped_item_node : Node3D = null # нода оружия (для того чтобы не проходится по массиву каждый раз)
var equiped_slot: InSlotData = null # слот, который в данный момент выбран
var equiped_item: ItemData = null # айтем в этом слоте (для удобства, так как айтем можно получить через equiped_slot.item)
var equiped_slot_index : int # индекс equip слота нужен для переключения активного слота

var Scoped = false
var toggle_holo = false # переключение прицела
var toggle_silencer = false # переключение глушителя

var def_pos_holder_z : float
var def_holder_pos : Vector3

var def_pos_sight : Vector3
var def_pos: Vector3
var def_rot: Vector3
var target_rot: Vector3
var target_pos: Vector3
var current_time: float

var spread_value : float

var building_scene

func _ready():
	randomize() # чтобы разброс оружия работал
	Global.global_item_script = self
	$"../fp_player_model2/fp_player_model/Skeleton3D/SkeletonIK3DRight".start()
	$"../fp_player_model2/fp_player_model/Skeleton3D/SkeletonIK3DLeft".start()
	# для удобства
	for weapon_node in fp_items_array:
		if weapon_node and weapon_node.visible:
			weapon_node.hide()
	if fp_player_model.visible:
		fp_player_model.hide()
	#

func _physics_process(delta):
	if _equiped_item_type(equiped_item.ItemType.weapon): # если соответствует тип
		if Global.check_is_inventory_open() == false: # проверка если закрыт инвентарь
			if Input.is_action_pressed("fire"):
				if equiped_item.fire_mode_current.mode == WeaponFireModes.FireMode.FULL_AUTO:
					if can_shoot(equiped_item.fire_mode_current):
						shoot()
			if Input.is_action_pressed("right_click"):
				if state_machine.is_current_state("Sprint") == false:
					if !Scoped and animator.current_animation != equiped_item.anim_reload and animator.current_animation != equiped_item.anim_activate:
						Assault_Rifle_Scope()
						reticle.hide()
						crosshair.hide()
		if current_time < 1:
			apply_recoil(delta)
		elif Global.check_is_inventory_open() == true or state_machine.is_current_state("Sprint") == true:
			if Scoped:
				crosshair.show()
				Assault_Rifle_Scope()
	elif _equiped_item_type(equiped_item.ItemType.building):
		if building_cast and building_scene:
			if building_cast.is_colliding():
				var collider_interact = building_cast.get_collider()
				var coll_point = building_cast.get_collision_point()
				building_scene.is_in_building_place = false
				building_scene.hide()
				if collider_interact:
					if collider_interact.is_in_group("floor_colliders"):
						match equiped_item.building_type:
							equiped_item.BuildingType.floor:
								if !collider_interact.connected_floor:
									building_scene.show()
									building_scene.global_transform.origin = collider_interact.get_child(2).global_transform.origin
									building_scene.is_in_building_place = true
							equiped_item.BuildingType.wall:
								if !collider_interact.connected_wall:
									if collider_interact.is_in_group("collider_side"):
										building_scene.rotation_degrees.y = 0
									else:
										building_scene.rotation_degrees.y = 90
									building_scene.show()
									building_scene.global_transform.origin = collider_interact.get_child(1).global_transform.origin
									building_scene.is_in_building_place = true
					if collider_interact.is_in_group("collider_wall"):
						match equiped_item.building_type:
							equiped_item.BuildingType.roof:
								if !collider_interact.connected_roof:
									building_scene.show()
									building_scene.global_transform.origin = collider_interact.get_child(1).global_transform.origin
									building_scene.is_in_building_place = true
				else: # если нету контакта луча с коллайдерами построек
					match equiped_item.building_type:
						equiped_item.BuildingType.floor:
							building_scene.show()
							building_scene.is_in_building_place = false
							building_scene.global_transform.origin = Vector3(coll_point.x, coll_point.y + 0.2, coll_point.z)
				if building_scene.is_in_building_place == true:
					building_scene.building_part_shape.enabled = false
				else:
					if building_scene.building_part_shape.enabled == false:
						building_scene.building_part_shape.enabled = true
				building_scene.can_be_placed = true
				if building_scene.shape_cast.is_colliding() \
				# shape_cast который контактирует с player и interactable items
				or building_scene.building_part_shape.is_colliding() \
				# building_part_shape который контактирует с подзоной building_part_area чужой постройки чтоб нельзя было ее построить в упор 
				or building_scene.disable_building_collider.is_colliding() \
				# disable_building_collider проверяет столковения с указанными слоями
				or building_scene.able_to_building == false: # проверка на чужую приват зону постройки
					building_scene.can_be_placed = false
				if !building_scene.can_be_placed:
					building_scene.mesh_building.material.albedo_color = Color(1, 0, 0) # красный
				if building_scene.can_be_placed and building_scene.visible:
					building_scene.mesh_building.material.albedo_color = Color(0, 1, 0) # зелёный
					if Input.is_action_just_pressed("fire"):
						place_building_part()
			else:
				if building_scene.visible:
					building_scene.hide() # нет коллайдеров в принципе, поэтому скрываем визуальный объект
					building_scene.can_be_placed = false

func place_building_part():
	var path = load(equiped_item.dictionary["scene_path"])
	var instance = path.instantiate()
	for coll in instance.colliders:
		if coll:
			coll.get_child(0).disabled = false # включаем коллайдеры к которым подсоединяется постройка
	player.buildings_in_own.append(instance)
	instance.building_part_owner = player
	Global.global_world.add_child(instance)
	instance.global_transform = building_scene.global_transform
	#instance.mesh_building.mesh = building_scene.mesh_building.mesh
	instance.mesh_building.material.albedo_color = Color(1, 1, 1)
	instance.mesh_building.use_collision = true # включаем коллизию меша для того чтобы игрок мог ходить по объекту
	# pizda
	instance.temporary_building_area.get_child(0).disabled = true # отключаем коллайдер, который запрещает строить если контактирует с чужой приват зоной
	instance.building_part_area.get_child(0).disabled = false # включаем коллайдер, в его зоне нельзя разместить объект, но только если он не подсоеденён к коллайдерам остальных объектов
	instance.building_part_shape.enabled = false # отключаем шейп каст, который контактирует с зоной выше(building_part_area)
	instance.shape_cast.enabled = false # отключаем шейп каст который контактирует с player и interactable items
	instance.disable_building_collider.enabled = false # отключаем шейп каст, который контактирует с указанными слоями
	instance.private_area.get_child(0).disabled = false # включаем приватную зону строительства у этой постройки
	#
	instance.mesh_building.cast_shadow = 1
	remove_active_item(player.player_quick_slot, equiped_slot_index, equiped_slot)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if Global.check_is_inventory_open() == false and !animator.is_playing(): # проверка если закрыт инвентарь
			match event.keycode:
				KEY_1:
					swap_items(Global.global_player_quick_slot, 0)
				KEY_2:
					swap_items(Global.global_player_quick_slot, 1)
				KEY_3:
					swap_items(Global.global_player_quick_slot, 2)
				KEY_4:
					swap_items(Global.global_player_quick_slot, 3)
				KEY_5:
					swap_items(Global.global_player_quick_slot, 4)
				KEY_6:
					swap_items(Global.global_player_quick_slot, 5)
				KEY_0:
					if _equiped_item_type(equiped_item.ItemType.weapon):
						pass
						toggle_holo_sight() # На кнопку 0 можно переключать меш прицела, если его меш выставлен в ItemDataWeapon для оружия
	
	if Global.check_is_inventory_open() == false: # проверка если закрыт инвентарь
		if Input.is_action_just_pressed("fire"):
			if _equiped_item_type(equiped_item.ItemType.tool) and !animator.is_playing():
				if equiped_item.anim_hit:
					animator.play(equiped_item.anim_hit)
		if _equiped_item_type(equiped_item.ItemType.weapon) and animator.current_animation != equiped_item.anim_activate and animator.current_animation != equiped_item.anim_reload: # если соответствует тип
			if Input.is_action_just_pressed("reload") and equiped_item.ammo_current != equiped_item.ammo_max and equiped_item.ammo_reserve and animator.current_animation != equiped_item.anim_scope:
				if Scoped:
					Assault_Rifle_Scope()
				reticle.show()
				crosshair.hide()
				animator.play(equiped_item.anim_reload)
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
				for mode in equiped_item.fire_modes:
					if mode and mode != equiped_item.fire_mode_current:
						equiped_item.fire_mode_current = mode
						Update_Fire_Mode.emit(equiped_item.fire_mode_current)
						break

func initialize(inventory_data : InventoryData, slot_index : int, item_slot: InSlotData): # создаем либо свапаем предмет в руках / принимаем данные из item_slot и назначаем меш предмета
	if item_slot == null:
		return
	clear_animations() # очистка анимации предмета если проигрывается в данный момент
	clear_building()
	inventory_data.signal_update_active_slot.emit(inventory_data, slot_index, equiped_slot_index, item_slot, equiped_slot)
	#-назначаем основные переменные этого класса
	equiped_slot = item_slot
	equiped_item = equiped_slot.item
	equiped_slot_index = slot_index
	#-
	set_IK_targets_position() # выставляем позиции для рук
	for weapon_node in fp_items_array: # все отображаемое оружие в руках находится в этом массиве
		if weapon_node:
			if weapon_node.weapon_name == equiped_item.name:
				fp_animator.play(weapon_node.fp_animation_name)
				weapon_node.show()
				equiped_item_node = weapon_node
			else:
				if weapon_node.visible:
					weapon_node.hide()
	if !fp_player_model.visible: # если нода модельки рук скрыта, отображаем ее 
		fp_player_model.show()
	if _equiped_item_type(equiped_item.ItemType.weapon):
		for data in player.weapon_spread_data:
			if data and data.weapon_data.name == equiped_item.name:
				player.current_weapon_spread_data = data # выставляется ресурс с данными о разбросе для оружия
		weapon_hud.show()
		crosshair.show()
		reticle.hide()
		Update_Ammo.emit([equiped_item.ammo_current, equiped_item.ammo_reserve])
		Update_Fire_Mode.emit(equiped_item.fire_mode_current)
		update_pos(equiped_item) # получение первоначальной позиции для разброса во время стрельбы
		set_weapon_attachments() # добавляются либо удаляются обвесы на оружие
		animator.play(equiped_item.anim_activate)
	if _equiped_item_type(equiped_item.ItemType.weapon) == false:
		clear_weapon()
	if _equiped_item_type(equiped_item.ItemType.building):
		if equiped_item.dictionary.has("scene_path"):
			var path = load(equiped_item.dictionary["scene_path"])
			building_scene = path.instantiate()
			Global.global_world.add_child(building_scene)
			building_scene.building_part_owner = player
			#building_scene.mesh_building.mesh = equiped_item.mesh
			# в process выставляется позиция для building_scene

func remove_active_item(inventory_data : InventoryData, index : int, slot_data : InSlotData): # убираем предмет из рук
	clear_animations() # очистка анимации предмета если проигрывается в данный момент
	#
	if _equiped_item_type(equiped_item.ItemType.weapon):
		clear_weapon()
	#
	fp_player_model.hide()
	equiped_item_node.hide()
	clear_building()
	inventory_data.signal_update_active_slot.emit(inventory_data, index, equiped_slot_index, slot_data, equiped_slot)
	player.current_weapon_spread_data = null
	reticle.show()
	equiped_slot = null
	equiped_item = null
	equiped_item_node = null
	clear_weapon_hud() # убираем перекрестие и hud
	clear_weapon_attachments() # очищаем меш прицела если он не null
	
	
func clear_weapon():
	clear_weapon_attachments() # очищаем меш прицела если он не null
	clear_weapon_hud() # убираем перекрестие и hud

func clear_building():
	if building_scene:
		building_scene.queue_free()
		building_scene = null
	
func clear_animations():
	if equiped_item:
		if animator and animator.is_playing():
			animator.stop()
		if Scoped:
			Scoped = false

func set_IK_targets_position():
	target_l.position = equiped_item.IK_pos_target_left
	target_l.rotation_degrees = equiped_item.IK_rot_target_left
	target_r.position = equiped_item.IK_pos_target_right
	target_r.rotation_degrees = equiped_item.IK_rot_target_right

func apply_recoil(delta):
	current_time += delta
	var recoil_speed = current_time * equiped_item.recoil_speed
	if !Scoped:
		def_pos_holder_z = def_pos.z
	else:
		def_pos_holder_z = def_pos_sight.z
	fp_items.position.z = lerp(fp_items.position.z, def_pos_holder_z + target_pos.z, equiped_item.lerp_speed * delta)
	fp_items.rotation.z = lerp(fp_items.rotation.z, def_rot.z + target_rot.z, equiped_item.lerp_speed * delta)
	fp_items.rotation.x = lerp(fp_items.rotation.x, def_rot.x + target_rot.x, equiped_item.lerp_speed * delta)
	player.rotation.y = lerp(player.rotation.y, player.rotation.y + equiped_item.recoil_rotation_x.sample(current_time) * equiped_item.recoil_amplitude.x * 1.5, equiped_item.lerp_speed * delta)
	camera_holder.rotation.x = lerp(camera_holder.rotation.x, camera_holder.rotation.x + equiped_item.recoil_rotation_z.sample(current_time) * equiped_item.recoil_amplitude.y * 1.5, equiped_item.lerp_speed * delta)
	camera_holder.rotation.x = clamp(camera_holder.rotation.x, deg_to_rad(-85), deg_to_rad(85))
	target_pos.z = equiped_item.recoil_position_z.sample(recoil_speed) * equiped_item.recoil_amplitude.z
	target_rot.z = equiped_item.recoil_rotation_z.sample(recoil_speed) * equiped_item.recoil_amplitude.y
	target_rot.x = equiped_item.recoil_rotation_x.sample(recoil_speed) * -equiped_item.recoil_amplitude.x

func shoot():
	randomize_aimcast_spread()
	hitscan(aim_cast)
	update_weapon_ammo(-1) # отнимаем current ammo и обновляем худ
	equiped_item.recoil_amplitude.x *= -1 if randf() > 0.75 else 1
	target_rot.z = equiped_item.recoil_rotation_z.sample(0) * equiped_item.recoil_amplitude.y
	target_rot.x = equiped_item.recoil_rotation_x.sample(0) * equiped_item.recoil_amplitude.x
	target_pos.z = equiped_item.recoil_position_z.sample(0) * equiped_item.recoil_amplitude.z
	current_time = 0

func update_pos(weapon_data : ItemData):
	def_pos = weapon_data.position
	def_pos_sight = weapon_data.in_sight_position
	def_rot = Vector3.ZERO#weapon_data.rotation
	target_rot.y = 0.0
	current_time = 1
	
func hitscan(raycast : RayCast3D):
	var target = raycast.get_collider()
	var ray_end_point = raycast.get_collision_point()
	if ray_end_point:
		var decal = BULLET_DECAL.instantiate()
		if target:
			target.add_child(decal)
		else:
			Global.global_world.add_child(decal)
		decal.global_transform.origin = ray_end_point
		var side : Vector3
		if raycast.get_collision_normal() == Vector3.UP:
			side = Vector3(1,0,0)
		elif raycast.get_collision_normal() == Vector3.DOWN:
			side = Vector3(-1,0,0)
		else:
			side = Vector3(0,1,0)
		decal.look_at(ray_end_point + raycast.get_collision_normal(), side)
	if target:
		if raycast == melee_cast and equiped_item.ItemType.tool:
			if target.is_in_group("world_resource"):
				target.health -= randf_range(equiped_item.damage, equiped_item.damage * 2)
			if equiped_item.tool_type == equiped_item.ToolType.pickaxe and target.is_in_group("stone_object"):
				create_player_item(load("res://inventory/item/objects/resource_stone.tres"), randi_range(2,6))
			if equiped_item.tool_type == equiped_item.ToolType.axe and target.is_in_group("pine_tree_object"):
				create_player_item(load("res://inventory/item/objects/resource_pine_wood.tres"), randi_range(2,6))
		if target.is_in_group("enemy_group"):
			target.health -= equiped_item.damage
			

func randomize_aimcast_spread():
	spread_value = reticle.spread_factors * 10 # умножается на 10 в случае если длина луча 1000+ метров
	aim_cast.target_position.x = randf_range(-spread_value,spread_value)
	aim_cast.target_position.y = randf_range(-spread_value,spread_value)
	
func reload():
	reticle.hide()
	crosshair.show()
	var ammo_to_reload = min(equiped_item.ammo_reserve, equiped_item.ammo_max - equiped_item.ammo_current)
	equiped_item.ammo_current += ammo_to_reload
	equiped_item.ammo_reserve -= ammo_to_reload
	Update_Ammo.emit([equiped_item.ammo_current, equiped_item.ammo_reserve])

func Assault_Rifle_Scope():
	if !Scoped:
		animator.play(equiped_item.anim_scope)
	else:
		animator.play_backwards(equiped_item.anim_scope)
	Scoped = !Scoped
	
func toggle_holo_sight():
	if equiped_item.sight_mesh != null and equiped_item.muzzle_mesh != null:
		toggle_holo = !toggle_holo
		toggle_silencer = !toggle_silencer
		if !toggle_silencer:
			silencer.mesh = equiped_item.muzzle_mesh
		if !toggle_holo:
			holo.mesh = equiped_item.sight_mesh
		else:
			holo.mesh = null
			silencer.mesh = null

func set_weapon_attachments():
	if equiped_item.sight_mesh:
		holo.mesh = equiped_item.sight_mesh
	if equiped_item.muzzle_mesh:
		silencer.mesh = equiped_item.muzzle_mesh
	else:
		clear_weapon_attachments()
			

func clear_weapon_attachments():
	if holo.mesh:
		holo.mesh = null
	if silencer.mesh:
		silencer.mesh = null

func clear_weapon_hud():
	if weapon_hud.visible:
		weapon_hud.hide()
	if crosshair.visible: # разделение перекрестия и точки
		crosshair.hide()
	reticle.show()

func update_weapon_ammo(value : int):
	equiped_item.ammo_current += value
	Update_Ammo.emit([equiped_item.ammo_current, equiped_item.ammo_reserve])
	
func swap_items(inventory_data : InventoryData, index : int):
	var slot_data = inventory_data.slots_data[index]
	for i in index+1:
		match[slot_data, equiped_slot, index]:
			[null, null, i]:
				print("Niche nety v rykah i slot pystoi")
				inventory_data.signal_update_active_slot.emit(inventory_data, index, equiped_slot_index, slot_data, equiped_slot)
				break 
			[null, _, i]:
				print("Item removed")
				remove_active_item(inventory_data, index, slot_data)
				break
			[_, null, i]:
				print("Item equiped %s" % slot_data.item.name)
				initialize(inventory_data, index, slot_data)
				break
			[_,_, i]:
				if equiped_slot != slot_data:
					print("Item changed to %s" % slot_data.item.name)
					initialize(inventory_data, index, slot_data)
				else:
					print("Item removed")
					remove_active_item(inventory_data, index, slot_data)
				break

func _equiped_item_type(equiped_item_type : int) -> bool:
	if equiped_item:
		match equiped_item.item_type:
			equiped_item_type:
				return true
			_:
				return false
	else:
		return false

func can_shoot(fire_mode : WeaponFireModes) -> bool:
	if Global.check_is_inventory_open() or state_machine.is_current_state("Sprint") \
		or timer.is_stopped() == false or equiped_item.ammo_current == 0 \
		or animator.current_animation == equiped_item.anim_reload or animator.current_animation == equiped_item.anim_activate:
		return false
	else:
		timer.start(fire_mode.fire_rate)
		return true

func _on_anim_item_animation_finished(anim_name):
	if _equiped_item_type(equiped_item.ItemType.weapon):
		if anim_name == equiped_item.anim_reload:
			reload()
	if _equiped_item_type(equiped_item.ItemType.tool):
		if anim_name == equiped_item.anim_hit:
			hitscan(melee_cast)
			animator.play(equiped_item.anim_after_hit)

func create_player_item(item_data : ItemData, amount : int):
	var slot_data = InSlotData.new()
	slot_data.item = item_data
	slot_data.amount_in_slot = amount
	Global.give_player_item(slot_data)
