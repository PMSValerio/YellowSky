extends CanvasLayer

onready var health_bar_ref = $Control/VBoxContainer/HealthBar
onready var stamina_bar_ref = $Control/VBoxContainer/StaminaBar

func _on_Player_stamina_changed(stamina_val):
	stamina_bar_ref.value = stamina_val

func _on_Player_health_changed(health_val):
	health_bar_ref.value = health_val
	
