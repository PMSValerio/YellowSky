extends Control


var list_item_scene = preload("res://src/gui/menus/facility_type/FacilityListItem.tscn")
const TMP_COST = 100

signal type_chosen

onready var type_list = $MarginContainer/PanelContainer/HBoxContainer/VBoxContainer/ScrollContainer/TypeList
onready var type_name = $MarginContainer/PanelContainer/HBoxContainer/TypeDetail/Name
onready var type_art = $MarginContainer/PanelContainer/HBoxContainer/TypeDetail/Art
# onready var type_stats = ...

var facility_entity = null # the actual facility node

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
		
		_set_type_details(null)


func _set_type_details(type : FacilityType):
	if type == null:
		type_name.text = ""
		type_art.texture = null
	else:
		type_name.text = type.type_name
		type_art.texture = type.portrait_texture


func _on_type_select(type) -> void:
	selected_type = type
	_set_type_details(type)


func _on_type_confirm():
	if facility_entity != null and selected_type.type_id in Global.FacilityTypes.values():
		facility_entity.set_type(selected_type.type_id)
	emit_signal("type_chosen")
