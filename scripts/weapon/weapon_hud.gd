extends Node

func _on_item_update_ammo(ammo_amount: int) -> void:
	%CurrentAmmo.set_text(str(ammo_amount))

func _on_item_update_fire_mode(fire_mode: WeaponFireModes) -> void:
	%FireMode.set_text(fire_mode.name)
