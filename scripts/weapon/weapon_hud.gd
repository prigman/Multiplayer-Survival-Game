extends Node

func _on_item_update_ammo(ammo_amount: int) -> void:
	if multiplayer.is_server(): return
	%CurrentAmmo.set_text(str(ammo_amount))

func _on_item_update_fire_mode(fire_mode: WeaponFireModes) -> void:
	if multiplayer.is_server(): return
	%FireMode.set_text(fire_mode.name)
