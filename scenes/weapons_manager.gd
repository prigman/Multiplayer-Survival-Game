extends Node3D

@onready var anim_player = %AnimationPlayer

var weapon_current = null
var weapon_stack = [] # all weapons in the game
var weapon_indicator = 0
var weapon_next : String
var weapon_list = {}
@export var weapon_resources : Array[WeaponResources]
@export var on_game_start_weapon : Array[String] 
var weapon_equiped = false

func _ready():
	initialize(on_game_start_weapon) # enter the state machine

func _input(_event):
	if(Input.is_action_pressed("2")):
		weapon_indicator = min(weapon_indicator + 1, weapon_stack.size() - 1)
		exit(weapon_stack[weapon_indicator])
	if(Input.is_action_pressed("1")):
		weapon_indicator = max(weapon_indicator - 1, 0)
		exit(weapon_stack[weapon_indicator])
 
func initialize(_weapons_on_start: Array):
	for weapon in weapon_resources:
		weapon_list[weapon.name] = weapon
	
	for i in _weapons_on_start:
		weapon_stack.push_back(i) # add start weapons
		
	weapon_current = weapon_list[weapon_stack[0]] # set the first weapon in the stack to current
	enter()
	
func enter(): # calls when first entering into a weapon
	anim_player.queue(weapon_current.anim_activate)

func exit(_exit_weapon_next : String):
	if(_exit_weapon_next != weapon_current.name):
		if anim_player.get_current_animation() != weapon_current.anim_deactivate:
			anim_player.play(weapon_current)
			weapon_next = _exit_weapon_next

func weapon_change(_weapon_name: String):
	weapon_current = weapon_list[_weapon_name]
	weapon_next = ""
	enter()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == weapon_current.anim_deactivate:
		weapon_change(weapon_next)
