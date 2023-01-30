extends Control


var list_item_scene = preload("res://src/gui/menus/facility/type/FacilityListItem.tscn")
const TMP_COST = 100 # TODO

signal type_chosen

onready var confirm_button = $MarginContainer/HBoxContainer/VBoxContainer/ConfirmButton
onready var type_list = $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/ScrollContainer/TypeList
onready var name_panel = $MarginContainer/HBoxContainer/TypeDetail/PanelContainer
onready var type_name = $MarginContainer/HBoxContainer/TypeDetail/PanelContainer/Name
onready var type_art = $MarginContainer/HBoxContainer/TypeDetail/Art
onready var stats = $MarginContainer/HBoxContainer/TypeDetail/HBoxContainer

onready var max_health = $MarginContainer/HBoxContainer/TypeDetail/HBoxContainer/VBoxContainer2/PanelContainer/Integrity
onready var max_fuel = $MarginContainer/HBoxContainer/TypeDetail/HBoxContainer/VBoxContainer2/PanelContainer2/MaxFuel
onready var max_prod = $MarginContainer/HBoxContainer/TypeDetail/HBoxContainer/VBoxContainer2/PanelContainer3/MaxProd

onready var cons_rate = $MarginContainer/HBoxContainer/TypeDetail/HBoxContainer/VBoxContainer/PanelContainer/ConsumptionRate
onready var fuel_list = $MarginContainer/HBoxContainer/TypeDetail/HBoxContainer/VBoxContainer/FuelList
onready var prod_rate = $MarginContainer/HBoxContainer/TypeDetail/HBoxContainer/VBoxContainer/PanelContainer2/ProductionRate
onready var prod_list = $MarginContainer/HBoxContainer/TypeDetail/HBoxContainer/VBoxContainer/ProdList

var facility_entity : Facility = null # the actual facility node

var selected_type = -1


func _ready() -> void:
	# this should probably be changed to the list of types available for the player
	for type_key in WorldData.unlocked_facilities:
		var type = Global.facility_types[type_key] as FacilityType
		if type.type_id != Global.FacilityTypes.WRECKED:
			var list_item = list_item_scene.instance()
			list_item.set_state(type)
			list_item.connect("pressed", self, "_on_type_select", [type])
			type_list.add_child(list_item)


func set_context(context):
	if context is Feature: # close enough
		facility_entity = context
		confirm_button.disabled = true
		_set_type_details(facility_entity.facility_type if facility_entity.facility_type.type_id != Global.FacilityTypes.WRECKED else null)


func _set_type_details(type : FacilityType):
	if type == null:
		type_name.text = ""
		name_panel.visible = false
		type_art.texture = null
		stats.visible = false
	else:
		type_name.text = type.type_name
		name_panel.visible = true
		type_art.texture = type.portrait_texture
		stats.visible = true
	
		max_health.text = str(type.max_health)
		max_fuel.text = str(type.max_fuel)
		max_prod.text = str(type.max_prod)
		
		cons_rate.text = "-" + str(type.consumption_rate) + str(" / sec")
		prod_rate.text = "+" + str(type.production_rate) + str(" / sec")
		
		var f_ix = 0
		for c in fuel_list.get_children():
			var rec = -1
			if f_ix < type.fuel_types.size():
				rec = type.fuel_types[f_ix]
			if rec != -1:
				c.visible = true
				c.init(rec, 32)
			else:
				c.visible = false
			f_ix += 1
		
		var p_ix = 0
		for c in prod_list.get_children():
			var rec = -1
			if p_ix < type.product_types.size():
				rec = type.product_types[p_ix]
			if rec != -1:
				c.visible = true
				c.init(rec, 32)
			else:
				c.visible = false
			p_ix += 1


func _on_type_select(type) -> void:
	selected_type = type
	confirm_button.disabled = facility_entity.facility_type.type_id == type.type_id
	_set_type_details(type)


func _on_type_confirm():
	if facility_entity != null and selected_type.type_id in Global.FacilityTypes.values() && ResourceManager.get_resource(Global.Resources.MATERIALS) >= selected_type.build_cost:
		ResourceManager.add_to_resource(Global.Resources.MATERIALS, -selected_type.build_cost)
		facility_entity.set_type(selected_type.type_id)
		facility_entity.repair(facility_entity.get_max_health())
		emit_signal("type_chosen")
