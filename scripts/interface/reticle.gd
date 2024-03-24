extends CenterContainer

@export var dot_radius = 1.0
@export var dot_color = Color.WHITE
@export var state_machine : StateMachine
@export var reticle_lines : Array[Line2D]
@export var player : CharacterBody3D
@export var crosshair_speed = 0.15
var crosshair_range : float = 0 # дефолтное значение разброса в перекрестии
var velocity_value : Vector3
var origin : Vector3
var player_velocity : float = 0
var shooting_multiplier_value : float = 0
var spread_factors : float = 0 # все факторы разброса

func _ready():
	queue_redraw()

func _process(_delta):
	adjust_reticle_lines()
	
func _draw():
	draw_circle(Vector2(0,0), dot_radius, dot_color)

func adjust_reticle_lines():
	velocity_value = player.get_real_velocity()
	origin = Vector3(0, 0, 0)
	player_velocity = origin.distance_to(velocity_value)
	if player.item.Scoped:
		crosshair_range = player.spread_radius / player.in_sight_multiplier
	else:
		crosshair_range = player.spread_radius
	if state_machine.is_current_state("Crouch"):
		crosshair_range /= player.crouch_state_multiplier
	if player.item.timer.is_stopped() == false:
		if crosshair_range < 1:
			shooting_multiplier_value = crosshair_range * -player.shooting_state_multiplier
		else:
			shooting_multiplier_value = crosshair_range * player.shooting_state_multiplier
	else:
		shooting_multiplier_value = 0
	spread_factors = crosshair_range + (player_velocity + shooting_multiplier_value) * player.all_factors_multiplier
	reticle_lines[0].position = lerp(reticle_lines[0].position, Vector2(0, -spread_factors), crosshair_speed) 
	reticle_lines[1].position = lerp(reticle_lines[1].position, Vector2(spread_factors, 0), crosshair_speed)
	reticle_lines[2].position = lerp(reticle_lines[2].position, Vector2(0, spread_factors), crosshair_speed)
	reticle_lines[3].position = lerp(reticle_lines[3].position, Vector2(-spread_factors, 0), crosshair_speed)
