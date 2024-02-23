extends Node

@onready var current_weapon = %CurrentWeapon
@onready var current_ammo = %CurrentAmmo
@onready var weapon_stack = %WeaponStack


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Hello:%s" % weapon_stack)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_weapons_manager_update_ammo(ammo):
	%CurrentAmmo.set_text(str(ammo[0])+" / "+str(ammo[1]))
	


func _on_weapons_manager_update_weapon_stack(sweapon_stack):
	%WeaponStack.set_text("1")
	for i in sweapon_stack:
		%WeaponStack.text += "\n"+i
		
	


func _on_weapons_manager_weapon_changed(weapon_name):
	%CurrentWeapon.set_text(weapon_name)
