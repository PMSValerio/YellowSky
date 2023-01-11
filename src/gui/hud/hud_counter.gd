extends MarginContainer


signal action


func set_resource(rec_id):
	$MarginContainer/HBoxContainer/TextureRect.texture = Global.resource_icons[rec_id]


func set_value(value):
	$MarginContainer/HBoxContainer/Label.text = str(value)


func _on_Button_pressed() -> void:
	emit_signal("action")
