extends Node

func _on_item_update_ammo(ammo):
	%CurrentAmmo.set_text(str(ammo[0])+" / "+str(ammo[1]))

func _on_item_update_fire_mode(fire_mode : WeaponFireModes):
	%FireMode.set_text(fire_mode.name)
