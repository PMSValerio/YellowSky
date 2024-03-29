extends MarginContainer


signal pressed

var data : FacilityType

func set_state(type_data):
	data = type_data
	$HBoxContainer/ProductIcon.texture = data.icon_texture
	$HBoxContainer/Name.text = data.type_name
	$HBoxContainer/HBoxContainer/Cost.text = str(data.build_cost)
	$HBoxContainer/HBoxContainer/ResourceIcon.init(Global.Resources.MATERIALS, 16)


func _on_Button_pressed() -> void:
	emit_signal("pressed")
