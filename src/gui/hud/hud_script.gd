extends CanvasLayer

onready var health_bar_ref = $Control/MarginContainer/AllElements/Bars/Health/TextureProgress
onready var stamina_bar_ref = $Control/MarginContainer/AllElements/Bars/Stamina/TextureProgress
onready var water_counter_ref = $Control/MarginContainer/AllElements/Resources/WaterCounter
onready var materials_counter_ref = $Control/MarginContainer/AllElements/Resources/CraftMatCounter
onready var energy_counter_ref = $Control/MarginContainer/AllElements/Resources/EnergyCounter
onready var seeds_counter_ref = $Control/MarginContainer/AllElements/SeedsCounter

func _ready():
	var _v = EventManager.connect("resource_changed", self, "on_resource_changed")
	
	# For testing purposes only
	ResourceManager.add_to_resource(Global.Resources.ENERGY, 200)
	ResourceManager.add_to_resource(Global.Resources.MATERIALS, 200)
	ResourceManager.add_to_resource(Global.Resources.WATER, 200)
	ResourceManager.add_to_resource(Global.Resources.SEEDS, 200)
	
	water_counter_ref.set_resource(Global.Resources.WATER)
	water_counter_ref.connect("action", self, "_on_resource_button_pressed", [Global.Resources.WATER])
	materials_counter_ref.set_resource(Global.Resources.MATERIALS)
	materials_counter_ref.connect("action", self, "_on_resource_button_pressed", [Global.Resources.MATERIALS])
	energy_counter_ref.set_resource(Global.Resources.ENERGY)
	energy_counter_ref.connect("action", self, "_on_resource_button_pressed", [Global.Resources.ENERGY])
	
	seeds_counter_ref.set_resource(Global.Resources.SEEDS)


func on_resource_changed(type, new_val):
	match type:
		Global.Resources.WATER:
			water_counter_ref.set_value(new_val)
		Global.Resources.MATERIALS:
			materials_counter_ref.set_value(new_val)
		Global.Resources.ENERGY:
			energy_counter_ref.set_value(new_val)
		Global.Resources.SEEDS:
			seeds_counter_ref.set_value(new_val)


func _on_Player_stamina_changed(stamina_val):
	stamina_bar_ref.value = stamina_val

func _on_Player_health_changed(health_val):
	health_bar_ref.value = health_val

func _on_Inventory_pressed():
	EventManager.emit_signal("push_menu", Global.Menus.MAIN_MENU, null)

func _on_Skills_pressed():
	EventManager.emit_signal("push_menu", Global.Menus.TEST, null)

func _on_resource_button_pressed(rec_id):
	var gui = get_parent().get_node("GUI") # this is very very bad code, don't do this at home
	if gui.get_current_menu() == Global.Menus.MAIN_MENU:
		EventManager.emit_signal("change_compact_resource", rec_id)
	else:
		EventManager.emit_signal("push_menu", Global.Menus.MAIN_MENU, rec_id)
