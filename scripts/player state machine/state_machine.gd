class_name StateMachine
extends Node

@export var player: CharacterBody3D
@export var current_state : State
var states: Dictionary = {}

func _ready():
	if not player.is_multiplayer_authority():
		return
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transition.connect(on_child_transition)
		else:
			push_warning("State machine contains incompatible child node")
	current_state.enter(current_state)
	
func _process(delta):
	if not player.is_multiplayer_authority():
		return
	current_state.update(delta)
	Global.global_debug.add_property("state", current_state.name, +1)
	
func _physics_process(delta):
	if not player.is_multiplayer_authority():
		return
	current_state.physics_update(delta)
	
func on_child_transition(new_state_name: StringName) -> void:
	var new_state = states.get(new_state_name)
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
