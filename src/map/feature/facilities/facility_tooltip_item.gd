extends MarginContainer


func set_state(rec, value) -> void:
	$HBoxContainer/ResourceIcon.init(rec, 32)
	$HBoxContainer/Label.text = str(value)
