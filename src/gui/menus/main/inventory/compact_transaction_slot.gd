extends Button
class_name CompactTransactionSlot

onready var icon_texture = $MarginContainer/HBoxContainer/Icon
onready var name_label = $MarginContainer/HBoxContainer/VBoxContainer/Name
onready var stat = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/GridContainer/Stat
onready var resource_icon = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/GridContainer/ResourceIcon
onready var cost_label = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Cost
onready var value = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/GridContainer/Value

var data : Item = null
var cost


func set_state(item_data : Item, is_disabled : bool, _cost : int) -> void:
	data = item_data
	cost = _cost
	icon_texture.texture = item_data.texture
	name_label.text = item_data.name
	
	stat.text = str(item_data.stat)
	stat.get_node("MenuTooltipProxy").hint_tooltip = Global.resource_names[item_data.subtype] + " value when used"
	resource_icon.init(item_data.subtype, 24)
	value.text = str(item_data.value)
	
	cost_label.text = str(cost)
	cost_label.get_node("MenuTooltipProxy").hint_tooltip = Global.resource_names[item_data.subtype] + " cost"
	if is_disabled:
		cost_label.add_color_override("font_color", Color("#a32c2c"))
	else:
		cost_label.remove_color_override("font_color")
	
	disabled = is_disabled
	
	$MarginContainer.visible = true


func clear():
	data = null
	cost = -1
	
	icon_texture.texture = null
	name_label.text = ""
	
	stat.text = ""
	stat.get_node("MenuTooltipProxy").hint_tooltip = ""
	resource_icon.clear()
	value.text = ""
	
	cost_label.text = ""
	cost_label.get_node("MenuTooltipProxy").hint_tooltip = ""
	
	disabled = true
	$MarginContainer.visible = false
