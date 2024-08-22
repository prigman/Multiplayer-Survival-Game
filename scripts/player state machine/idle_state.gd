extends PlayerMovementState
class_name IdleState

@export var speed_state := 5.0
var fall_damage: float
var fall_distance: float

func physics_update(delta : float) -> void:
    player.update_gravity(delta)
    player.update_input(speed_state, ACCELERATION, DECCELERATION)
    player.update_velocity()

    if player.is_on_floor():
        if Input.is_action_pressed("left_ctrl"):
            transition.emit("Crouch")
        elif player.velocity.length() > 0.0:
            transition.emit("Walking")
        elif Input.is_action_just_pressed("space"):
            transition.emit("Jump")
    else:
        if player.velocity.y != 0:
            transition.emit("Falling")

func enter(previous_state : State) -> void:
    if previous_state is FallingState:
        fall_distance = previous_state.start_fall_y - player.global_transform.origin.y
        if fall_distance > 4:
            fall_damage = fall_distance * 1.5 
            player.died_process(fall_damage)
            #print("Player took fall damage: ", fall_damage)

