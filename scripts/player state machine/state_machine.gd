class_name StateMachine
extends Node

@export var current_state_name : String
@export var current_state : State
@export var player : CharacterBody3D
var states: Dictionary = {}

func _ready() -> void:
	if not multiplayer.is_server():
		return
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transition.connect(on_child_transition)
		else:
			push_warning("State machine contains incompatible child node")
	current_state.enter(current_state)
	
func _process(delta : float) -> void:
	# if not is_multiplayer_authority():
	# 	return
	if multiplayer.is_server(): 
		current_state.update(delta)
		current_state_name = current_state.name
	elif multiplayer.get_unique_id() == player.peer_id:
		player.debug_ui.add_property("state", current_state_name, +1)
	
func _physics_process(delta : float) -> void:
	# if not is_multiplayer_authority():
	# 	return
	if not multiplayer.is_server(): return
	current_state.physics_update(delta)
	
func on_child_transition(new_state_name: StringName) -> void:
	# if not is_multiplayer_authority(): return
	# if not multiplayer.is_server(): return
	# if multiplayer.get_unique_id() == player.peer_id:
	# 	rpc("RPC_state_transition", new_state_name)
	var new_state : State = states.get(new_state_name)
	if new_state != null:
		if new_state != current_state:
			current_state.exit()
			new_state.enter(current_state)
			current_state = new_state
	else:
		push_warning("State does not exist")
	
func is_current_state(state_name : StringName) -> bool:
	if current_state.name == state_name:
		return true
	else:
		return false

# @rpc("any_peer", "call_local", "unreliable", 0)
# func RPC_state_transition(new_state_name : StringName) -> void:
# 	var new_state : State = states.get(new_state_name)
# 	if new_state != null:
# 		if new_state != current_state:
# 			current_state.exit()
# 			new_state.enter(current_state)
# 			current_state = new_state
# 	else:
# 		push_warning("State does not exist")
