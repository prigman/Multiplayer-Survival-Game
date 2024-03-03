extends PanelContainer

@onready var health_bar = %HealthBar
@onready var hunger_bar = %HungerBar


func _on_player_signal_update_player_stats(health : float, hunger : float):
	health_bar.value = health
	hunger_bar.value = hunger


func _on_player_signal_update_player_health(health : float):
	health_bar.value = health


func _on_player_signal_update_player_hunger(hunger : float):
	hunger_bar.value = hunger
