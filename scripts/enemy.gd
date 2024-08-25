extends CharacterBody3D

signal signal_connect_mob_to_player(mob : CharacterBody3D)

const SPEED := 4

@export var navigation_agent : NavigationAgent3D
@export var health : float
@export var max_health : float = 120.0
@export var target : Player
@export var death_timer : Timer
@export var collision : CollisionShape3D
@export var mesh : MeshInstance3D
@export var collision_target_area : CollisionShape3D
@export var label : Label3D

func _ready() -> void:
	# if not multiplayer.is_server(): return
	health = max_health

func _physics_process(_delta : float) -> void:
	if not multiplayer.is_server(): return
	if target:
		var current_location := global_transform.origin
		var next_location := navigation_agent.get_next_path_position()
		var new_velocity := (next_location - current_location).normalized() * SPEED
		velocity = new_velocity
		navigation_agent.target_position = target.global_transform.origin
		move_and_slide()

func _process(_delta : float) -> void:
	if not multiplayer.is_server(): return

@rpc("any_peer","reliable","call_local")
func damage_enemy(damage:float, damage_peer_id: int = -1) -> void:
	health -= damage
	# signal_update_player_health.emit(health_value)
	print("DAMAGE LOG: " + name + " was hit by " + str(damage_peer_id) + " | with damage: " + str(damage) + " | health now: " + str(health))
	if health <= 0:
		if target:
			target.rpc_id(1, "disconnect_mob_from_player", get_path())
		toggle_enemy(false) # false - died
		death_timer.start()
		print("DEATH LOG: " + str(name) + " killed by " + str(damage_peer_id))

func toggle_enemy(toggle : bool) -> void:
	if toggle:
		mesh.show()
		label.show()
		collision.disabled = false
		collision_target_area.disabled = false
	else:
		mesh.hide()
		label.hide()
		collision.disabled = true
		collision_target_area.disabled = true
	set_physics_process(toggle)
	set_process(toggle)

func _on_target_detection_body_entered(body: CharacterBody3D) -> void:
	if not multiplayer.is_server(): return
	if target and target != body:
		target.rpc_id(1, "disconnect_mob_from_player", get_path())	
	body.rpc_id(1, "connect_mob_to_player", get_path())

func _on_death_timer_timeout() -> void:
	toggle_enemy(true)
	health = max_health
	var random_range := randf_range(-5.0, 5.0)
	transform.origin = Vector3(random_range, 0, random_range)
