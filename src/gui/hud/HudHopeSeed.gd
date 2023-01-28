extends PanelContainer


func set_resource(rec_id):
	$HBoxContainer/TextureRect.texture = Global.resource_icons[rec_id]


func set_value(value):
	$HBoxContainer/Label.text = str(value)
