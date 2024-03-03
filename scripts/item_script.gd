extends Node3D

signal Weapon_Changed
signal Update_Ammo
signal Update_Weapon_Stack(stack)

@onready var item_mesh: MeshInstance3D = %ItemMesh # MeshInstance нода айтема куда назначается меш из переменной mesh в ItemData
@onready var weapon_sight_mesh: MeshInstance3D = %WeaponSight # дубликат предыдущей ноды, но с иной позицией, сюда назначается меш прицела из ItemDataWeapon

@onready var player = $"../../.."

@export var animator: AnimationPlayer
@export var weapon_hud: VBoxContainer
@export var reticle: CenterContainer # перекрестие и точка
@export var crosshair: Control # только перекрестие

@export var state_machine: StateMachine

var equiped_slot: InSlotData = null # слот, который в данный момент выбран
var equiped_item: ItemData = null # айтем в этом слоте (для удобства, так как айтем можно получить через equiped_slot.item)

var Scoped = false
var toggle_holo = false # переключение прицела

var def_pos: Vector3
var def_rot: Vector3
var target_rot: Vector3
var target_pos: Vector3
var current_time: float

func _physics_process(delta):
		if Input.is_action_pressed("right_click"):
			if !player.inventory_interface.visible: # проверка если закрыт инвентарь
				if equiped_item:
					if equiped_item.item_type == equiped_item.ItemType.weapon:
						if state_machine.is_current_state("Sprint") == false:
							if !Scoped:
								Assault_Rifle_Scope()
								reticle.hide()
		if (Input.is_action_just_pressed("fire")):
			if !player.inventory_interface.visible: # проверка если закрыт инвентарь
				if equiped_item:
					if equiped_item.item_type == equiped_item.ItemType.weapon:
						if state_machine.is_current_state("Sprint") == false:
							apply_recoil()
							if current_time < 1:
								shoot(delta)
		if Scoped:
			if player.inventory_interface.visible or state_machine.is_current_state("Sprint"):
				reticle.show()
				Assault_Rifle_Scope()

func _unhandled_input(event):
	if !player.inventory_interface.visible: # проверка если закрыт инвентарь
		if equiped_item:
			if equiped_item.item_type == equiped_item.ItemType.weapon:
				if event is InputEventKey:
					if event.keycode == KEY_0 and event.is_pressed(): # На кнопку 0 можно переключать меш прицела, если он выставлен в ItemDataWeapon для оружия
						toggle_holo_sight()
				if (Input.is_action_just_pressed("reload")):
					reload()
				if Input.is_action_just_released("right_click"):
					if Scoped:
						Assault_Rifle_Scope()
						reticle.show()

func initialize(item_slot: InSlotData): # создаем либо свапаем предмет в руках / принимаем данные из item_slot и назначаем меш предмета
	if item_slot != null:
		equiped_slot = item_slot
		equiped_item = equiped_slot.item
		set_mesh_and_loc() # выставляются данные меша, позиции, размер, поворот этой ноды из класса ItemData
		if equiped_item.item_type == equiped_item.ItemType.weapon:
			weapon_hud.show()
			crosshair.show()
			animator.play(equiped_item.anim_activate)
			Weapon_Changed.emit(equiped_item.name)
			Update_Ammo.emit([equiped_item.ammo_current, equiped_item.ammo_reserve])
			current_time = 1
			update_pos()
			set_holo_sight() # удаляется или создаётся меш прицела если он выставлен в ItemDataWeapon для оружия
		else:
			clear_weapon_attachments() # убираем перекрестие, очищаем меш прицела если он не null

func remove_item(): # убираем предмет из рук
	item_mesh.mesh = null
	equiped_slot = null
	equiped_item = null
	position = Vector3.ZERO
	rotation_degrees = Vector3.ZERO
	scale = Vector3.ZERO
	clear_weapon_attachments() # убираем перекрестие, очищаем меш прицела если он не null

#=====

func shoot(delta):
	current_time += delta * equiped_item.recoil_speed
	print("Test1 current_time", current_time)
	position.z = lerp(position.z, def_pos.z + target_pos.z, equiped_item.lerp_speed * delta)
	rotation.z = lerp(rotation.z, def_rot.z + target_rot.z, equiped_item.lerp_speed * delta)
	rotation.x = lerp(rotation.x, def_rot.x + target_rot.x, equiped_item.lerp_speed * delta)
	target_rot.z = equiped_item.recoil_rotation_z.sample(current_time) * equiped_item.recoil_amplitude.y
	target_rot.x = equiped_item.recoil_rotation_x.sample(current_time) * - equiped_item.recoil_amplitude.x
	target_pos.z = equiped_item.recoil_position_z.sample(current_time) * equiped_item.recoil_amplitude.z
	
	update_weapon_ammo(-1) # отнимаем current ammo и обновляем худ

func apply_recoil():
	print("Test1 recoil")
	equiped_item.recoil_amplitude.y *= - 1 if randf() > 0.5 else 1
	target_rot.z = equiped_item.recoil_rotation_z.sample(0) * equiped_item.recoil_amplitude.y
	target_rot.x = equiped_item.recoil_rotation_x.sample(0) * - equiped_item.recoil_amplitude.x
	target_pos.z = equiped_item.recoil_position_z.sample(0) * equiped_item.recoil_amplitude.z
	current_time = 0

func update_pos():
	def_pos = position
	def_rot = rotation
	target_rot.y = rotation.y
	
#=====

func reload():
	animator.play(equiped_item.anim_reload)
	
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
	toggle_holo = !toggle_holo
	if equiped_item.sight_mesh != null:
		if !toggle_holo:
			weapon_sight_mesh.mesh = equiped_item.sight_mesh
		else:
			weapon_sight_mesh.mesh = null

func set_holo_sight():
	if equiped_item.sight_mesh:
		weapon_sight_mesh.mesh = equiped_item.sight_mesh
	else:
		if weapon_sight_mesh.mesh:
			weapon_sight_mesh.mesh = null

func clear_weapon_attachments():
	if weapon_sight_mesh.mesh != null: # очистка меша прицела
		weapon_sight_mesh.mesh = null
	if weapon_hud.visible:
		weapon_hud.hide()
	if crosshair.visible: # разделение перекрестия и точки
		crosshair.hide()

func update_weapon_ammo(value : int):
	equiped_item.ammo_current += value
	Update_Ammo.emit([equiped_item.ammo_current, equiped_item.ammo_reserve])
