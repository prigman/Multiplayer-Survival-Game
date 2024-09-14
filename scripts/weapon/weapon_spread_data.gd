class_name PlayerWeaponSpread extends Resource

@export var weapon_data : ItemData

# переменные разброса для оружия
@export var spread_radius : float = 10

# spread_radius делится на эти значения
@export var in_sight_multiplier : float = 4
@export var crouch_state_multiplier : float = 2.5
@export var shooting_state_multiplier : float = 2

@export var all_factors_multiplier : float = 2 # все факторы разброса умножаются на это значение
