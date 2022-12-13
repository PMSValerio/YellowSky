extends CanvasLayer

onready var health_bar_ref = $Control/AllElements/Bars/Health/TextureProgress
onready var stamina_bar_ref = $Control/AllElements/Bars/Stamina/TextureProgress
onready var water_counter_ref = $Control/AllElements/Resources/WaterCounter/HBoxContainer/Label
onready var materials_counter_ref = $Control/AllElements/Resources/CraftMatCounter/HBoxContainer/Label
onready var energy_counter_ref = $Control/AllElements/Resources/EnergyCounter/HBoxContainer/Label
onready var seeds_counter_ref = $Control/AllElements/Other/SeedsCounter/HBoxContainer/Label

func _ready():
	var _v = EventManager.connect("resource_changed", self, "on_resource_changed")

	# For testing purposes only
	ResourceManager.add_to_resource(Global.Resources.WATER, 200)
	ResourceManager.add_to_resource(Global.Resources.MATERIALS, 200)
	ResourceManager.add_to_resource(Global.Resources.ENERGY, 200)
	ResourceManager.add_to_resource(Global.Resources.SEEDS, 200)

func on_resource_changed(type, new_val):
	match type:
		Global.Resources.WATER:
			water_counter_ref.text = str(new_val)
		Global.Resources.MATERIALS:
			materials_counter_ref.text = str(new_val)
		Global.Resources.ENERGY:
			energy_counter_ref.text = str(new_val)
		Global.Resources.SEEDS:
			seeds_counter_ref.text = str(new_val)


func _on_Player_stamina_changed(stamina_val):
	stamina_bar_ref.value = stamina_val

func _on_Player_health_changed(health_val):
	health_bar_ref.value = health_val

func _on_Inventory_pressed():
	EventManager.emit_signal("push_menu", Global.Menus.MAIN_MENU, null)

func _on_Skills_pressed():
	EventManager.emit_signal("push_menu", Global.Menus.TEST, null)
