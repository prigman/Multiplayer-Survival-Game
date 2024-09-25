class_name State
extends Node

signal transition(new_state_name: StringName)

func enter(_previous_state : State) -> void:
	pass
	
func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

# @rpc("any_peer","call_local","unreliable",0)
# func RPC_emit_state_transition(state_name : String) -> void:
# 	transition.emit(state_name)