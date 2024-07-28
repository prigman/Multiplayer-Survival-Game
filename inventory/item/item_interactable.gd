extends RigidBody3D

@export var slot_data : InSlotData
@export var synchronizer : MultiplayerSynchronizer
@export var network_id : int

func _player_interact(player: Player) -> bool:
	if player.give_item(slot_data) == true:
		return true
	else:
		print("Inventory and quick slots are full")
		return false

# @rpc("any_peer", "reliable", "call_local")
# func delete_item() -> void:
# 	if not is_multiplayer_authority(): return
# 	print("SERVER: delete_item function called on item %s" % get_node(get_path()).name)
# 	queue_free()

