extends Node3D

signal Weapon_Changed
signal Update_Ammo
signal Update_Weapon_Stack(stack)

@onready var item_mesh : MeshInstance3D = %ItemMesh

@export var item_data : ItemData = null#:
	#set(value):
		#item_data = value
		#if Engine.is_editor_hint():
			#set_mesh_and_loc()

@export var animator : AnimationPlayer
@export var weapon_hud : VBoxContainer
@export var reticle : CenterContainer
@export var state_machine : StateMachine

var equiped_slot : InSlotData = null

var Scoped = false

func _physics_process(_delta):
	if Input.is_action_pressed("right_click"):
		if item_data:
			if item_data.item_type == item_data.ItemType.weapon:
				if state_machine.is_current_state("Sprint") == false:
					if !Scoped:
						Assault_Rifle_Scope()
						reticle.hide()
	if Scoped:
		if state_machine.is_current_state("Sprint"):
			reticle.show()
			Assault_Rifle_Scope()

func _unhandled_input(_event):
	if item_data:
		if item_data.item_type == item_data.ItemType.weapon:
			if(Input.is_action_just_pressed("reload")):
				reload()
			if(Input.is_action_just_pressed("fire")):
				if !Scoped:
					shoot()
					##--- переделать (пример)
					#weapon_current.ammo_current -= 1
					#Update_Ammo.emit([weapon_current.ammo_current, weapon_current.ammo_reserve])
					##--- 
			if Input.is_action_just_released("right_click"):
				if Scoped:
					Assault_Rifle_Scope()
					reticle.show()

func initialize(slot_data : InSlotData):
	if slot_data.item != null:
		if item_data:
			remove_item()
		var item = slot_data.item
		item_data = item
		set_mesh_and_loc()
		equiped_slot = slot_data
		if item_data.item_type == item_data.ItemType.weapon:
			weapon_hud.show()
			#animator.play(item_data.anim_activate)
			Weapon_Changed.emit(item_data.name)
			Update_Ammo.emit([item_data.ammo_current, item_data.ammo_reserve])
			pass

func set_mesh_and_loc():
	item_mesh.mesh = item_data.mesh
	position = item_data.position
	rotation_degrees = item_data.rotation
	scale = item_data.scale

func remove_item():
	if item_data != null:
		item_mesh.mesh = null
		if item_data.item_type == item_data.ItemType.weapon:
			#animator.play_backwards(item_data.anim_activate)
			weapon_hud.hide()
		item_data = null
		position = Vector3.ZERO
		rotation_degrees = Vector3.ZERO
		scale = Vector3.ZERO

func shoot():
	animator.play(item_data.anim_shoot)

func reload():
	animator.play(item_data.anim_reload)

func Assault_Rifle_Scope():
	if !Scoped:
		animator.play(item_data.anim_scope)
	else:
		animator.play_backwards(item_data.anim_scope)
	Scoped = !Scoped


func _on_player_signal_update_equiped_item(inventory : InventoryData, slot_index : int):
	if inventory.slots_data[slot_index] != null:
		if item_data == inventory.slots_data[slot_index].item:
			remove_item()
		else:
			initialize(inventory.slots_data[slot_index])
	else:
		if item_data: 
			remove_item()
