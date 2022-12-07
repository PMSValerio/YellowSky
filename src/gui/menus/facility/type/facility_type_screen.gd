extends Control


var list_item_scene = preload("res://src/gui/menus/facility/type/FacilityListItem.tscn")
const TMP_COST = 100 # TODO

signal type_chosen

onready var confirm_button = $MarginContainer/PanelContainer/HBoxContainer/VBoxContainer/ConfirmButton
onready var type_list = $MarginContainer/PanelContainer/HBoxContainer/VBoxContainer/PanelContainer/ScrollContainer/TypeList
onready var type_name = $MarginContainer/PanelContainer/HBoxContainer/TypeDetail/Name
onready var type_art = $MarginContainer/PanelContainer/HBoxContainer/TypeDetail/Art
onready var stats = $MarginContainer/PanelContainer/HBoxContainer/TypeDetail/HBoxContainer

onready var max_health = $MarginContainer/PanelContainer/HBoxContainer/TypeDetail/HBoxContainer/BaseStats/VBoxContainer/PanelContainer/Integrity
onready var max_fuel = $MarginContainer/PanelContainer/HBoxContainer/TypeDetail/HBoxContainer/BaseStats/VBoxContainer/PanelContainer2/MaxFuel
onready var max_prod = $MarginContainer/PanelContainer/HBoxContainer/TypeDetail/HBoxContainer/BaseStats/VBoxContainer/PanelContainer3/MaxProd

onready var cons_rate = $MarginContainer/PanelContainer/HBoxContainer/TypeDetail/HBoxContainer/OperationStats/VBoxContainer/PanelContainer/ConsumptionRate
onready var fuel_list = $MarginContainer/PanelContainer/HBoxContainer/TypeDetail/HBoxContainer/OperationStats/VBoxContainer/FuelList
onready var prod_rate = $MarginContainer/PanelContainer/HBoxContainer/TypeDetail/HBoxContainer/OperationStats/VBoxContainer/PanelContainer2/ProductionRate
onready var prod_list = $MarginContainer/PanelContainer/HBoxContainer/TypeDetail/HBoxContainer/OperationStats/VBoxContainer/ProdList

var facility_entity : Facility = null # the actual facility node

var selected_type = -1


func _ready() -> void:
	# this should probably be changed to the list of types available for the player
	for type in Global.facility_types.values():
		type = type as FacilityType
		if type.type_id != Global.FacilityTypes.WRECKED:
			var list_item = list_item_scene.instance()
			list_item.set_state(type, TMP_COST)
			list_item.connect("pressed", self, "_on_type_select", [type])
			type_list.add_child(list_item)


func set_context(context):
	if context is Feature: # close enough
		facility_entity = context
		confirm_button.disabled = true
		_set_type_details(null)


func _set_type_details(type : FacilityType):
	if type == null:
		type_name.text = ""
		type_art.texture = null
		stats.visible = false
	else:
		type_name.text = type.type_name
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
			if p_ix < 0:
				pass
			if rec != -1:
				c.visible = true
				c.init(rec, 32)
			else:
				c.visible = false
			p_ix += 1
		# TODO: change
		prod_list.get_child(0).visible = true
		prod_list.get_child(0).init(type.product_type, 32)


func _on_type_select(type) -> void:
	selected_type = type
	confirm_button.disabled = false
	_set_type_details(type)


func _on_type_confirm():
	if facility_entity != null and selected_type.type_id in Global.FacilityTypes.values():
		facility_entity.set_type(selected_type.type_id)
		facility_entity.repair(facility_entity.get_max_health())
	emit_signal("type_chosen")
