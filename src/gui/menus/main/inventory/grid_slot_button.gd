extends Button

var data : Item = null


func _make_custom_tooltip(_for_text) -> Control:
	var tooltip = Global.grid_slot_tooltip.instance()
	if tooltip != null && data != null:
		tooltip.set_name(data.name)
		tooltip.set_value(str(data.value))

	return tooltip
	
