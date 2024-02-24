extends Node3D

signal Weapon_Changed
signal Update_Ammo
signal Update_Weapon_Stack(stack)



@onready var player = $"../../.."

@onready var anim_player = $"../AnimationPlayer"

var weapon_current = null
var weapon_stack = [] # all weapons in the game
var weapon_indicator = 0
var weapon_next : String
var weapon_list = {}
@export var weapon_resources : Array[WeaponResources]
@export var on_game_start_weapon : Array[String] 
var weapon_equiped = false

func _ready():
	pass

func _physics_process(_delta):
	pass

func _unhandled_input(_event):
	if weapon_current:
		if(Input.is_action_just_pressed("reload")):
			reload()
			
		if(Input.is_action_just_pressed("fire")):
			shoot()
	
		
 
func initialize(weapon : InSlotData):
	weapon_current = weapon.item
	anim_player.queue(weapon_current.anim_activate)
	#Update_Weapon_Stack.emit(weapon_stack)
	#Weapon_Changed.emit(weapon_current.weapon.weapon_name)
	#Update_Ammo.emit([weapon_current.weapon.ammo_current, weapon_current.weapon.ammo_reserve])
	
func enter(): # calls when first entering into a weapon
	anim_player.queue(weapon_current.anim_activate)
	Update_Weapon_Stack.emit(weapon_stack)
	Weapon_Changed.emit(weapon_current.weapon_name)
	Update_Ammo.emit([weapon_current.ammo_current, weapon_current.ammo_reserve])

func exit(_exit_weapon_next : String):
	if(_exit_weapon_next != weapon_current.weapon_name):
		if anim_player.get_current_animation() != weapon_current.anim_deactivate:
			anim_player.play(weapon_current)
			weapon_next = _exit_weapon_next

func weapon_change(_weapon_name: String):
	weapon_current = weapon_list[_weapon_name]
	weapon_next = ""
	enter()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == weapon_current:
		weapon_change(weapon_next)

func shoot():
	anim_player.play(weapon_current.anim_shoot)

func reload():
	anim_player.play(weapon_current.anim_reload)
	

