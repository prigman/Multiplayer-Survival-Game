extends RigidBody3D

@export var slot_data : InSlotData
@export var synchronizer : MultiplayerSynchronizer
@export var network_id : int

func _player_interact(player: Player) -> bool:
	if player.give_item(slot_data, false) == true:
		#rpc_id(player.peer_id, "RPC_give_item", player.get_path())
		return true
	else:
		print("Inventory and quick slots are full")
		return false


@rpc("any_peer", "reliable", "call_local", 2)
func RPC_give_item(player_node_path : NodePath) -> void:
	var player : Player = get_node(player_node_path)
	if player.give_item(slot_data, false) == true:
		player.rpc_id(1, "delete_item", get_path())
