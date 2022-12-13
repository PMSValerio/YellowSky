extends CanvasLayer

onready var health_bar_ref = $Control/MarginContainer/AllElements/Bars/Health/TextureProgress
onready var stamina_bar_ref = $Control/MarginContainer/AllElements/Bars/Stamina/TextureProgress
onready var water_counter_ref = $Control/MarginContainer/AllElements/Resources/WaterCounter/HBoxContainer/Label
onready var scraps_counter_ref = $Control/MarginContainer/AllElements/Resources/CraftMatCounter/HBoxContainer/Label
onready var energy_counter_ref = $Control/MarginContainer/AllElements/Resources/EnergyCounter/HBoxContainer/Label
onready var seeds_counter_ref = $Control/MarginContainer/AllElements/SeedsCounter/HBoxContainer/Label

func _on_Player_stamina_changed(stamina_val):
	stamina_bar_ref.value = stamina_val

func _on_Player_health_changed(health_val):
	health_bar_ref.value = health_val
	
func _on_ResourceManager_water_changed(water_val):
	water_counter_ref.text = str(water_val)

func _on_ResourceManager_craft_mat_changed(craft_mat_val):
	scraps_counter_ref.text = str(craft_mat_val)

func _on_ResourceManager_energy_changed(energy_val):
	energy_counter_ref.text = str(energy_val)

func _on_ResourceManager_seeds_changed(seeds_val):
	seeds_counter_ref.text = str(seeds_val)


func _on_Inventory_pressed():
	EventManager.emit_signal("push_menu", Global.Menus.MAIN_MENU, null)

func _on_Skills_pressed():
	EventManager.emit_signal("push_menu", Global.Menus.TEST, null)
