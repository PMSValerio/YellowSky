extends Control


signal want_rebuild

var stat_panel_scene = preload("res://src/gui/menus/facility/manage/StatDetails.tscn")

# Flavour Detail Elements
onready var name_label = $MarginContainer/HBoxContainer/DetailContainer/FlavourDetail/Name
onready var art_rect = $MarginContainer/HBoxContainer/DetailContainer/FlavourDetail/Art
onready var flavour_label = $MarginContainer/HBoxContainer/DetailContainer/FlavourDetail/FlavourText

onready var status_indicator = $MarginContainer/HBoxContainer/DetailContainer/FlavourDetail/Status

# --- || Stat Screen Elements || ---
onready var abandoned_panel = $MarginContainer/HBoxContainer/AbandonedPanel
onready var stats_container = $MarginContainer/HBoxContainer/StatsContainer

# Integrity Elements
onready var health_details = $MarginContainer/HBoxContainer/StatsContainer/StatsScreen/IntegrityRow/VBoxContainer2/HealthDetails
onready var status_marker = $MarginContainer/HBoxContainer/StatsContainer/StatsScreen/IntegrityRow/VBoxContainer/StatusMarker

# Resources Elements
onready var fuel_list = $MarginContainer/HBoxContainer/StatsContainer/StatsScreen/ResourcesRow/FuelContainer/VBoxContainer/FuelList
onready var prod_list = $MarginContainer/HBoxContainer/StatsContainer/StatsScreen/ResourcesRow/ProductContainer/VBoxContainer/ProdList
onready var cons_rate_label = $MarginContainer/HBoxContainer/StatsContainer/StatsScreen/ResourcesRow/FuelContainer/VBoxContainer/HBoxContainer/ConsumptionRate
onready var prod_rate_label = $MarginContainer/HBoxContainer/StatsContainer/StatsScreen/ResourcesRow/ProductContainer/VBoxContainer/HBoxContainer/ProductionRate

onready var resource_slider = $ResourceSlider


var facility_entity : Facility = null # the actual facility node
var fuel_stats_dict = {}
var prod_stats_dict = {}

onready var ResourceManager = Global.get_player().get_node("ResourceManager") # <- this is very bad, Resource should be global, maybe?

var slider_mode = 0 # 0: nothing; 1: repair; 2: refuel
var slider_resource = Global.FacilityResources.NONE


func _ready() -> void:
	var _v = health_details.connect("action_pressed", self, "_on_Repair_pressed") # doing this manually just cuz


func set_context(context):
	if context is Facility:
		facility_entity = context
		
		name_label.text = facility_entity.facility_type.type_name
		art_rect.texture = facility_entity.facility_type.portrait_texture
		flavour_label.text = facility_entity.facility_type.flavour_text
			
		if facility_entity.facility_type.type_id == Global.FacilityTypes.WRECKED:
			abandoned_panel.visible = true
			stats_container.visible = false
		else:
			abandoned_panel.visible = false
			stats_container.visible = true
			
			# set facility health details
			health_details.init(null, "", facility_entity.health, facility_entity.get_max_health(), "Repair")
			health_details.populate_data()
			
			# set fuels
			fuel_stats_dict.clear()
			for child in fuel_list.get_children():
				child.queue_free()
			for f in facility_entity.fuels.keys(): # in case a facility requires more than one fuel resource
				var fuel_details = stat_panel_scene.instance()
				fuel_details.init_resource(f, facility_entity.fuels[f], facility_entity.get_max_fuel(), "Refuel", 32)
				fuel_details.connect("action_pressed", self, "_on_Refuel_pressed", [f])
				fuel_list.add_child(fuel_details)
				fuel_stats_dict[f] = fuel_details
			
			# set products
			prod_stats_dict.clear()
			for child in prod_list.get_children():
				child.queue_free()
			var p = facility_entity.facility_type.product_type
			var prod_details = stat_panel_scene.instance()
			prod_details.init_resource(p, facility_entity.stored, facility_entity.get_max_prod(), "Collect", 32)
			prod_details.connect("action_pressed", self, "_on_Collect_pressed", [p])
			prod_list.add_child(prod_details)
			prod_stats_dict[p] = prod_details
			
			# set rates
			cons_rate_label.text = "-" + str(facility_entity.get_consumption_rate()) + str(" / sec")
			prod_rate_label.text = "+" + str(facility_entity.get_production_rate()) + str(" / sec")
		
		_update_status()


# set facility status
func _update_status():
	var status = facility_entity.get_status()
	
	status_indicator.text = Facility.Status.keys()[status]
	status_marker.text = "ON" if facility_entity.running else "OFF"
	
	# TODO: set appropriate colours and warnings


# this already assumes the player has enough resources for the operation
func _repair_by_amount(amount):
	if facility_entity != null:
		ResourceManager.add_to_resource(Global.FacilityResources.MATERIALS, -amount)
		facility_entity.repair(amount)
		health_details.set_x_out_of_y(facility_entity.health, facility_entity.get_max_health())
		_update_status()


# deposit amount of fuel; NOTE: this supports only one fuel type
func _deposit_fuel(amount, resource):
	if facility_entity != null:
		ResourceManager.add_to_resource(resource, -amount)
		facility_entity.refuel(amount, resource)
		fuel_stats_dict[resource].set_x_out_of_y(facility_entity.fuels[resource], facility_entity.get_max_fuel())
		_update_status()


# update both facility and player resources
func _collect_products(resource):
	if facility_entity != null:
		ResourceManager.add_to_resource(resource, facility_entity.stored)
		facility_entity.collect()
		prod_stats_dict[resource].set_x_out_of_y(facility_entity.stored, facility_entity.get_max_prod())
		_update_status()


# toggle facility on or off
func _toggle_on_off(onoff):
	facility_entity.toggle_facility(onoff)
	_update_status()


# || --- Callbacks --- ||

func _on_Repair_pressed() -> void:
	var amount = facility_entity.get_max_health() - facility_entity.health
	if amount > 0:
		var _min = facility_entity.health
		var _max = _min + ResourceManager.get_resource(Global.FacilityResources.MATERIALS)
		resource_slider.set_state(0, facility_entity.get_max_health(), _min, _max, Global.resource_icons[Global.FacilityResources.MATERIALS])
		resource_slider.visible = true
		slider_mode = 1
		slider_resource = Global.FacilityResources.MATERIALS


func _on_Refuel_pressed(resource) -> void:
	if facility_entity.health > 0:
		var _min = facility_entity.fuels[resource]
		var _max = _min + ResourceManager.get_resource(resource)
		resource_slider.set_state(0, facility_entity.get_max_fuel(), _min, _max, Global.resource_icons[resource])
		resource_slider.visible = true
		slider_mode = 2
		slider_resource = resource
	else:
		print("facility must first be repaired")


func _on_Collect_pressed(resource) -> void:
	if facility_entity.health > 0:
		_collect_products(resource)
	else:
		print("facility must first be repaired")


func _on_Rebuild_pressed() -> void:
	emit_signal("want_rebuild")


func _on_ResourceSlider_value_chosen(delta_value) -> void:
	match slider_mode:
		1:
			_repair_by_amount(delta_value)
		2:
			_deposit_fuel(delta_value, slider_resource)
	slider_mode = 0


func _on_OnOffButton_pressed() -> void:
	_toggle_on_off(not facility_entity.running)
