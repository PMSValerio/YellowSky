extends MarginContainer
class_name GridSlot

onready var button_node := $PanelContainer/Button

var data : Item = null
var amount : int = -1


func populate_data(item_data : Item, item_amount : int) -> void:
	$PanelContainer/Button/TextureRect.texture = item_data.texture
	data = item_data
	set_amount(item_amount)


func clear_data() -> void:
	$PanelContainer/Button/TextureRect.texture = null
	data = null
	amount = -1
	$PanelContainer/Button/Label.text = ""


func set_amount(item_amount) -> void:
	amount = item_amount
	$PanelContainer/Button/Label.text = "x" + str(amount)
