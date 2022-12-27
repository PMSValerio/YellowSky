extends "res://src/gui/menus/reusable/base_outer_menu.gd"


onready var manage_tab = $MarginContainer/PanelContainer/TabContainer/Manage
onready var type_tab = $MarginContainer/PanelContainer/TabContainer/Type
onready var upgrades_tab = $MarginContainer/PanelContainer/TabContainer/Upgrades

var _upgrades_removed = false


func _ready() -> void:
	set_up_facility()


# removes and alters the tab screens accordingly
# this cannot be done by overriding set_context both because of the order Godot calls _ready and my bad code
func set_up_facility() -> void:
	if _context is Facility:
		# if the facility type has not yet been chosen, hide the upgrades tab
		if _context.facility_type == null or _context.facility_type.type_id == Global.FacilityTypes.WRECKED:
			tabs.remove_child(upgrades_tab)
			_upgrades_removed = true


func _on_Type_type_chosen() -> void:
	# on choosing the type, change to manage screen
	manage_tab.set_context(type_tab.facility_entity)
	tabs.current_tab = 0
	type_tab.set_context(type_tab.facility_entity) # reset state
	if _upgrades_removed:
		tabs.add_child(upgrades_tab)
		_upgrades_removed = false


func _on_Manage_want_rebuild() -> void:
	tabs.current_tab = 1
