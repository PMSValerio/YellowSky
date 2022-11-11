extends CanvasLayer

onready var health_bar_ref = $Control/VBoxContainer/HealthBar
onready var stamina_bar_ref = $Control/VBoxContainer/StaminaBar
onready var water_counter_ref = $Control/HBoxContainer/WaterCounter/Panel/Label
onready var craft_mat_counter_ref = $Control/HBoxContainer/CraftMatCounter/Panel/Label
onready var energy_counter_ref = $Control/HBoxContainer/EnergyCounter/Panel/Label
onready var seeds_counter_ref = $Control/HBoxContainer/SeedsCounter/Panel/Label

func _on_Player_stamina_changed(stamina_val):
	stamina_bar_ref.value = stamina_val

func _on_Player_health_changed(health_val):
	health_bar_ref.value = health_val
	
func _on_ResourceManager_water_changed(water_val):
	water_counter_ref.text = str(water_val)

func _on_ResourceManager_craft_mat_changed(craft_mat_val):
	craft_mat_counter_ref.text = str(craft_mat_val)

func _on_ResourceManager_energy_changed(energy_val):
	energy_counter_ref.text = str(energy_val)

func _on_ResourceManager_seeds_changed(seeds_val):
	seeds_counter_ref.text = str(seeds_val)

