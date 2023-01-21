extends Control


func set_name(new_text) -> void:
	$PanelContainer/VBoxContainer/PanelName/Name.text = new_text


func set_value(new_value) -> void:
	$PanelContainer/VBoxContainer/PanelDescr/HBoxContainer/Value.text = new_value
