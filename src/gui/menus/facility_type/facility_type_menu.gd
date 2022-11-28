extends Control


var facility_entity = null # the actual facility node


func set_context(context):
	if context is Feature: # close enough
		facility_entity = context


func _facility_selected(type):
	if facility_entity != null:
		facility_entity.set_type(type)
	EventManager.emit_signal("pop_menu")


func _on_Materials_pressed() -> void:
	_facility_selected(Global.FacilityTypes.PARTS_WORKSHOP)


func _on_Energy_pressed() -> void:
	_facility_selected(Global.FacilityTypes.COAL_PLANT)
