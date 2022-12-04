extends Button
class_name CompactTransactionSlot

var data : Item = null
var cost


func set_state(item_data : Item, is_disabled : bool, _cost : int) -> void:
	data = item_data
	cost = _cost
	$HBoxContainer/Icon.texture = item_data.texture
	$HBoxContainer/VBoxContainer/Name.text = item_data.name
	
	$HBoxContainer/VBoxContainer/Stat.text = str(item_data.stat)
	$HBoxContainer/VBoxContainer/Value.text = str(item_data.value)
	
	$HBoxContainer/Cost.text = str(cost)
	if is_disabled:
		$HBoxContainer/Cost.add_color_override("font_color", Color("#a32c2c"))
	else:
		$HBoxContainer/Cost.remove_color_override("font_color")
	
	disabled = is_disabled


func clear():
	data = null
	cost = -1
	
	$HBoxContainer/Icon.texture = null
	$HBoxContainer/VBoxContainer/Name.text = ""
	
	$HBoxContainer/VBoxContainer/Stat.text = ""
	$HBoxContainer/VBoxContainer/Value.text = ""
	
	$HBoxContainer/Cost.text = ""
	
	disabled = true
