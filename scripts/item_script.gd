extends Node3D

signal Weapon_Changed
signal Update_Ammo
signal Update_Weapon_Stack(stack)

@onready var item_mesh : MeshInstance3D = %ItemMesh
@onready var weapon_sight_mesh : MeshInstance3D = %WeaponSight
@onready var player = $"../../.."

@export var animator : AnimationPlayer
@export var weapon_hud : VBoxContainer
@export var reticle : CenterContainer
@export var crosshair : Control

@export var state_machine : StateMachine

var equiped_slot : InSlotData = null
var equiped_item : ItemData = null

var Scoped = false
var toggle_holo = false

func _physics_process(_delta):
	if !player.inv_opened:
		if Input.is_action_pressed("right_click"):
			if equiped_item:
				if equiped_item.item_type == equiped_item.ItemType.weapon:
					if state_machine.is_current_state("Sprint") == false:
						if !Scoped:
							Assault_Rifle_Scope()
							reticle.hide()
		if Scoped:
			if state_machine.is_current_state("Sprint"):
				reticle.show()
				Assault_Rifle_Scope()

func _unhandled_input(event):
	if !player.inv_opened:
		if equiped_item:
			if equiped_item.item_type == equiped_item.ItemType.weapon:
				if event is InputEventKey:
					if event.keycode == KEY_0 and event.is_pressed():
						toggle_holo_sight()
				if(Input.is_action_just_pressed("reload")):
					reload()
				if(Input.is_action_just_pressed("fire")):
					if !Scoped:
						shoot()
						#--- переделать (пример)
						equiped_item.ammo_current -= 1
						Update_Ammo.emit([equiped_item.ammo_current, equiped_item.ammo_reserve])
						#--- 
				if Input.is_action_just_released("right_click"):
					if Scoped:
						Assault_Rifle_Scope()
						reticle.show()

func toggle_holo_sight():
	if !toggle_holo:
		weapon_sight_mesh.mesh = equiped_item.sight_mesh
	else:
		weapon_sight_mesh.mesh = null
	toggle_holo = !toggle_holo

func initialize(item_slot : InSlotData):
	if item_slot != null:
		equiped_slot = item_slot
		equiped_item = equiped_slot.item
		set_mesh_and_loc()
		if equiped_item.item_type == equiped_item.ItemType.weapon:
			weapon_hud.show()
			crosshair.show()
			animator.play(equiped_item.anim_activate)
			Weapon_Changed.emit(equiped_item.name)
			Update_Ammo.emit([equiped_item.ammo_current, equiped_item.ammo_reserve])
		elif weapon_hud.visible and crosshair.visible:
			weapon_hud.hide()
			crosshair.hide()

func set_mesh_and_loc():
	item_mesh.mesh = equiped_item.mesh
	position = equiped_item.position
	rotation_degrees = equiped_item.rotation
	scale = equiped_item.scale

func remove_item():
	if weapon_hud.visible and crosshair.visible:
		weapon_hud.hide()
		crosshair.hide()
	item_mesh.mesh = null
	equiped_slot = null
	equiped_item = null
	position = Vector3.ZERO
	rotation_degrees = Vector3.ZERO
	scale = Vector3.ZERO

func shoot():
	animator.play(equiped_item.anim_shoot)

func reload():
	animator.play(equiped_item.anim_reload)

func Assault_Rifle_Scope():
	if !Scoped:
		animator.play(equiped_item.anim_scope)
	else:
		animator.play_backwards(equiped_item.anim_scope)
	Scoped = !Scoped
