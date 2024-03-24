extends Node

func _on_item_update_ammo(ammo):
	%CurrentAmmo.set_text(str(ammo[0])+" / "+str(ammo[1]))

func _on_item_update_weapon_stack(sweapon_stack):
	%WeaponStack.set_text("1")
	for i in sweapon_stack:
		%WeaponStack.text += "\n"+i

func _on_item_weapon_changed(weapon_name):
	%CurrentWeapon.set_text(weapon_name)


func _on_item_update_fire_mode(fire_mode : WeaponFireModes):
	%FireMode.set_text(fire_mode.name)
