extends PanelContainer

@onready var health_bar := %HealthBar
@onready var hunger_bar := %HungerBar


func _on_player_signal_update_player_stats(health : float, hunger : float) -> void:
	health_bar.value = health
	hunger_bar.value = hunger


func _on_player_signal_update_player_health(health : float) -> void:
	health_bar.value = health


func _on_player_signal_update_player_hunger(hunger : float) -> void:
	hunger_bar.value = hunger
