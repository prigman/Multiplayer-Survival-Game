class_name ItemScript extends Node3D

signal Update_Ammo
signal Update_Fire_Mode(fire_mode : WeaponFireModes)

const BULLET_DECAL = preload("res://scenes/shoot_decal.tscn")

@onready var item_mesh: MeshInstance3D = %ItemMesh # MeshInstance нода айтема куда назначается меш из переменной mesh в ItemData
@onready var ar_sight_mesh: MeshInstance3D = %AR_sight # дубликат предыдущей ноды, но с иной позицией, сюда назначается меш прицела из ItemDataWeapon
@onready var ar_mag : MeshInstance3D = %AR_mag

@export var player : CharacterBody3D
@export var animator : AnimationPlayer
@export var weapon_hud: VBoxContainer
@export var reticle: CenterContainer # перекрестие и точка
@export var crosshair: Control # только перекрестие
@export var state_machine: StateMachine
@export var camera_holder : Node3D
@export var timer : Timer
@export var aim_cast : RayCast3D
@export var melee_cast : RayCast3D

var bullet_instance

var equiped_slot: InSlotData = null # слот, который в данный момент выбран
var equiped_item: ItemData = null # айтем в этом слоте (для удобства, так как айтем можно получить через equiped_slot.item)
var equiped_slot_index : int # индекс equip слота нужен для переключения активного слота

var Scoped = false
var toggle_holo = false # переключение прицела

var def_pos_holder_z : float
var def_holder_pos : Vector3

var def_pos_sight : Vector3
var def_pos: Vector3
var def_rot: Vector3
var target_rot: Vector3
var target_pos: Vector3
var current_time: float

var spread_value : float

func _ready():
	randomize() # чтобы разброс оружия работал
	Global.global_item_script = self

func _physics_process(delta):
	if Input.is_action_pressed("right_click"):
		if Global.check_is_inventory_open() == false: # проверка если закрыт инвентарь
			if _equiped_item_type(equiped_item.ItemType.weapon): # если соответствует тип
				if state_machine.is_current_state("Sprint") == false:
					if !Scoped and animator.current_animation != equiped_item.anim_reload and animator.current_animation != equiped_item.anim_activate:
						Assault_Rifle_Scope()
						reticle.hide()
						crosshair.hide()
	if _equiped_item_type(equiped_item.ItemType.weapon): # если соответствует тип
		if current_time < 1:
			apply_recoil(delta)
		if Input.is_action_pressed("fire"):
			if equiped_item.fire_mode_current.mode == WeaponFireModes.FireMode.FULL_AUTO:
				if can_shoot(equiped_item.fire_mode_current):
					shoot()
				
	if Scoped:
		if Global.check_is_inventory_open() == true or state_machine.is_current_state("Sprint"):
			crosshair.show()
			Assault_Rifle_Scope()

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if Global.check_is_inventory_open() == false: # проверка если закрыт инвентарь
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
						toggle_holo_sight() # На кнопку 0 можно переключать меш прицела, если его меш выставлен в ItemDataWeapon для оружия
	
	if Global.check_is_inventory_open() == false: # проверка если закрыт инвентарь
		if Input.is_action_just_pressed("fire"):
			if _equiped_item_type(equiped_item.ItemType.tool) and !animator.is_playing():
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
	if item_slot != null:
		inventory_data.signal_update_active_slot.emit(inventory_data, slot_index, equiped_slot_index, item_slot, equiped_slot)
		#-назначаем основные переменные этого класса
		equiped_slot = item_slot
		equiped_item = equiped_slot.item
		equiped_slot_index = slot_index
		#-
		set_mesh_and_loc() # выставляются данные меша, позиции, размер, поворот этой ноды из класса ItemData
		if equiped_item.item_type == equiped_item.ItemType.weapon:
			for data in player.weapon_spread_data:
				if data and data.weapon_data.name == equiped_item.name:
					player.current_weapon_spread_data = data # выставляется ресурс с данными о разбросе для оружия
			weapon_hud.show()
			crosshair.show()
			reticle.hide()
			animator.play(equiped_item.anim_activate)
			Update_Ammo.emit([equiped_item.ammo_current, equiped_item.ammo_reserve])
			Update_Fire_Mode.emit(equiped_item.fire_mode_current)
			update_pos(equiped_item)
			set_weapon_attachments() # удаляется или создаются меши из ItemDataWeapon
		else:
			clear_weapon_attachments() # убираем перекрестие, очищаем меш прицела если он не null

func remove_item(inventory_data : InventoryData, index : int, slot_data : InSlotData): # убираем предмет из рук
	inventory_data.signal_update_active_slot.emit(inventory_data, index, equiped_slot_index, slot_data, equiped_slot)
	player.current_weapon_spread_data = null
	reticle.show()
	item_mesh.mesh = null
	equiped_slot = null
	equiped_item = null
	position = Vector3.ZERO
	rotation_degrees = Vector3.ZERO
	scale = Vector3.ZERO
	clear_weapon_attachments() # убираем перекрестие, очищаем меш прицела если он не null

func apply_recoil(delta):
	current_time += delta
	var recoil_speed = current_time * equiped_item.recoil_speed
	if !Scoped:
		def_pos_holder_z = def_pos.z
	else:
		def_pos_holder_z = def_pos_sight.z
	position.z = lerp(position.z, def_pos_holder_z + target_pos.z, equiped_item.lerp_speed * delta)
	rotation.z = lerp(rotation.z, def_rot.z + target_rot.z, equiped_item.lerp_speed * delta)
	rotation.x = lerp(rotation.x, def_rot.x + target_rot.x, equiped_item.lerp_speed * delta)
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
	def_rot = weapon_data.rotation
	target_rot.y = weapon_data.rotation.y
	current_time = 1
	
func hitscan(raycast : RayCast3D):
	var target = raycast.get_collider()
	if target:
		if raycast == melee_cast and target.is_in_group("stone_object"):
			create_player_item(load("res://inventory/item/objects/resource_stone.tres"), randi_range(1, 5))
		if target.is_in_group("enemy_group"):
			print("Enemy hit")
			target.health -= equiped_item.damage
		else:
			var decal = BULLET_DECAL.instantiate()
			target.add_child(decal)
			decal.global_transform.origin = raycast.get_collision_point()
			if raycast.get_collision_normal() == Vector3.DOWN:
				decal.rotation_degrees.x = 90
			elif raycast.get_collision_normal() != Vector3.UP:
				decal.look_at(raycast.get_collision_point() - raycast.get_collision_normal(), Vector3(0,1,0))
			print("Hit collider %s" % target.name)
			

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
	
func set_mesh_and_loc():
	item_mesh.mesh = equiped_item.mesh
	position = equiped_item.position
	rotation_degrees = equiped_item.rotation
	scale = equiped_item.scale

func Assault_Rifle_Scope():
	if !Scoped:
		animator.play(equiped_item.anim_scope)
	else:
		animator.play_backwards(equiped_item.anim_scope)
	Scoped = !Scoped
	
func toggle_holo_sight():
	if equiped_item.sight_mesh != null:
		toggle_holo = !toggle_holo
		if !toggle_holo:
			ar_sight_mesh.mesh = equiped_item.sight_mesh
		else:
			ar_sight_mesh.mesh = null

func set_weapon_attachments():
	if equiped_item.mag_mesh:
		ar_mag.mesh = equiped_item.mag_mesh
	if equiped_item.sight_mesh:
		ar_sight_mesh.mesh = equiped_item.sight_mesh
	else:
		if ar_sight_mesh.mesh:
			ar_sight_mesh.mesh = null
		if ar_mag.mesh:
			ar_mag.mesh = null

func clear_weapon_attachments():
	if ar_sight_mesh.mesh != null: # очистка меша прицела
		ar_sight_mesh.mesh = null
	if ar_mag.mesh != null:
		ar_mag.mesh = null
	if weapon_hud.visible:
		weapon_hud.hide()
	if crosshair.visible: # разделение перекрестия и точки
		crosshair.hide()
	reticle.show()

func update_weapon_ammo(value : int):
	equiped_item.ammo_current += value
	Update_Ammo.emit([equiped_item.ammo_current, equiped_item.ammo_reserve])
	
func swap_items(inventory_data : InventoryData, index : int):
	if animator and equiped_item:
		if equiped_item.item_type == equiped_item.ItemType.weapon:
			if animator.current_animation == equiped_item.anim_reload:
				animator.stop()
			elif animator.current_animation == equiped_item.anim_activate:
				return
		elif equiped_item.item_type == equiped_item.ItemType.tool:
			if animator.is_playing():
				return
	var slot_data = inventory_data.slots_data[index]
	for i in index+1:
		match[slot_data, equiped_slot, index]:
			[null, null, i]:
				print("Niche nety v rykah i slot pystoi")
				inventory_data.signal_update_active_slot.emit(inventory_data, index, equiped_slot_index, slot_data, equiped_slot)
				break 
			[null, _, i]:
				print("Item removed")
				remove_item(inventory_data, index, slot_data)
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
					remove_item(inventory_data, index, slot_data)
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
	if equiped_item:
		if equiped_item.item_type == equiped_item.ItemType.weapon:
			if anim_name == equiped_item.anim_reload:
				reload()
		if equiped_item.item_type == equiped_item.ItemType.tool:
			if anim_name == equiped_item.anim_hit:
				hitscan(melee_cast)
				animator.play(equiped_item.anim_after_hit)

func create_player_item(item_data : ItemData, amount : int):
	var slot_data = InSlotData.new()
	slot_data.item = item_data
	slot_data.amount_in_slot = amount
	Global.give_player_item(slot_data)
