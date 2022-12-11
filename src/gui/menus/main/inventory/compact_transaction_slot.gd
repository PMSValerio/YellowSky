extends Button
class_name CompactTransactionSlot

onready var icon_texture = $MarginContainer/HBoxContainer/Icon
onready var name_label = $MarginContainer/HBoxContainer/VBoxContainer/Name
onready var stat = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2/Stat
onready var cost_label = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2/Cost
onready var value = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Value

var data : Item = null
var cost


func set_state(item_data : Item, is_disabled : bool, _cost : int) -> void:
	data = item_data
	cost = _cost
	icon_texture.texture = item_data.texture
	name_label.text = item_data.name
	
	stat.text = str(item_data.stat)
	value.text = str(item_data.value)
	
	cost_label.text = str(cost)
	if is_disabled:
		cost_label.add_color_override("font_color", Color("#a32c2c"))
	else:
		cost_label.remove_color_override("font_color")
	
	disabled = is_disabled


func clear():
	data = null
	cost = -1
	
	icon_texture.texture = null
	name_label.text = ""
	
	stat.text = ""
	value.text = ""
	
	cost_label.text = ""
	
	disabled = true
