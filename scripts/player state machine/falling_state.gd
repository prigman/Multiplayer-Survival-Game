extends PlayerMovementState
class_name FallingState

@export var speed_state := 5.0

var start_fall_y: float = 0.0

func physics_update(delta : float) -> void:
    player.update_gravity(delta)
    player.update_input(speed_state, ACCELERATION, DECCELERATION)
    player.update_velocity()
    if player.is_on_floor():
        transition.emit("Idle")

func enter(previous_state : State) -> void:
    start_fall_y = player.global_transform.origin.y
