extends MarginContainer


signal pressed

var data : FacilityType

func set_state(type_data, cost):
	data = type_data
	$HBoxContainer/ProductIcon.texture = Global.resource_icons[data.product_type]
	$HBoxContainer/Name.text = data.type_name
	$HBoxContainer/HBoxContainer/Cost.text = str(cost)


func _on_Button_pressed() -> void:
	emit_signal("pressed")
