extends Control


var stat_panel_scene = preload("res://src/gui/menus/facility_screen/StatDetails.tscn")

# Flavour Detail Elements
onready var name_label = $MarginContainer/HBoxContainer/DetailContainer/FlavourDetail/Name
onready var art_rect = $MarginContainer/HBoxContainer/DetailContainer/FlavourDetail/Art
onready var flavour_label = $MarginContainer/HBoxContainer/DetailContainer/FlavourDetail/FlavourText

# --- || Stat Screen Elements || ---
# Integrity Elements
onready var health_details = $MarginContainer/HBoxContainer/StatsContainer/StatsScreen/IntegrityRow/VBoxContainer2/HealthDetails
onready var status_marker = $MarginContainer/HBoxContainer/StatsContainer/StatsScreen/IntegrityRow/VBoxContainer/StatusMarker

# Resources Elements
onready var fuel_list = $MarginContainer/HBoxContainer/StatsContainer/StatsScreen/ResourcesRow/FuelContainer
onready var prod_list = $MarginContainer/HBoxContainer/StatsContainer/StatsScreen/ResourcesRow/ProductContainer

# Control Elements
onready var type_btn = $MarginContainer/HBoxContainer/StatsContainer/StatsScreen/ButtonsRow/TypeButton
onready var upgd_btn = $MarginContainer/HBoxContainer/StatsContainer/StatsScreen/ButtonsRow/UpgradesButton


var facility_entity : Facility = null # the actual facility node
var fuel_stats_dict = {}
var prod_stats_dict = {}

onready var ResourceManager = Global.get_player().get_node("ResourceManager") # <- this is very bad, Resource should be global, maybe?

var _readied = false


func _ready() -> void:
	_readied = true
	set_context(facility_entity)


func set_context(context):
	if not context is Facility:
		return
	facility_entity = context
	if _readied:
		name_label.text = Global.Resources.keys()[facility_entity.product_type]
		
		# set facility health details
		health_details.init(null, facility_entity.health, facility_entity.max_health, "Repair")
		health_details.populate_data()
		var _v = health_details.connect("action_pressed", self, "_on_Repair_pressed") # doing this manually just cuz
		
		# set fuels
		for f in facility_entity.fuels.keys(): # in case a facility requires more than one fuel resource
			var fuel_details = stat_panel_scene.instance()
			fuel_details.init(-1, facility_entity.fuels[f], facility_entity.tank, "Refuel")
			fuel_details.connect("action_pressed", self, "_on_Refuel_pressed", [f])
			fuel_list.get_node("VBoxContainer").add_child(fuel_details)
			fuel_stats_dict[f] = fuel_details
		
		# set products
		var p = facility_entity.product_type
		var prod_details = stat_panel_scene.instance()
		prod_details.init(-1, facility_entity.stored, facility_entity.capacity, "Collect")
		prod_details.connect("action_pressed", self, "_on_Collect_pressed", [p])
		prod_list.get_node("VBoxContainer").add_child(prod_details)
		prod_stats_dict[p] = prod_details


# this already assumes the player has enough resources for the operation
func _repair_by_amount(amount):
	if facility_entity != null:
		ResourceManager.add_to_resource(Global.Resources.MATERIALS, - amount)
		facility_entity.repair(amount)
		health_details.set_x_out_of_y(facility_entity.health, facility_entity.max_health)


# deposit amount of fuel; NOTE: this supports only one fuel type
func _deposit_fuel(amount, resource):
	if facility_entity != null:
		ResourceManager.add_to_resource(resource, -amount)
		facility_entity.refuel(amount, resource)
		fuel_stats_dict[resource].set_x_out_of_y(facility_entity.fuels[resource], facility_entity.tank)


# update both facility and player resources
func _collect_products(resource):
	if facility_entity != null:
		ResourceManager.add_to_resource(resource, facility_entity.stored)
		facility_entity.collect()
		prod_stats_dict[resource].set_x_out_of_y(facility_entity.stored, facility_entity.capacity)


func _on_ExitButton_pressed() -> void:
	EventManager.emit_signal("pop_menu")


# || --- TEMPORARY --- ||
# these methods should change to either bring up the appropriate sub menu or display other messages

func _on_Repair_pressed() -> void:
	var amount = facility_entity.max_health - facility_entity.health
	if amount > 0:
		_repair_by_amount(amount)
	else:
		print("already repaired")


func _on_Refuel_pressed(resource) -> void:
	if facility_entity.health > 0:
		_deposit_fuel(50, resource)
	else:
		print("facility must first be repaired")


func _on_Collect_pressed(resource) -> void:
	if facility_entity.health > 0:
		_collect_products(resource)
	else:
		print("facility must first be repaired")
